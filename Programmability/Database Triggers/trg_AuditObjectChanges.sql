SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 🔹 Crear trigger de auditoría integral
CREATE TRIGGER [trg_AuditObjectChanges]
ON DATABASE
FOR CREATE_PROCEDURE, ALTER_PROCEDURE, DROP_PROCEDURE,
    CREATE_FUNCTION, ALTER_FUNCTION, DROP_FUNCTION,
    CREATE_VIEW, ALTER_VIEW, DROP_VIEW,
    CREATE_TRIGGER, ALTER_TRIGGER, DROP_TRIGGER
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @EventData XML,
        @EventType NVARCHAR(50),
        @ObjectName NVARCHAR(255),
        @ObjectType NVARCHAR(100),
        @LoginName NVARCHAR(255),
        @TSQLCommand NVARCHAR(MAX),
        @HostName NVARCHAR(255),
        @DefinitionBefore NVARCHAR(MAX),
        @DefinitionAfter NVARCHAR(MAX),
        @DefinitionDiff NVARCHAR(MAX),
        @i INT = 0;

    SET @EventData = EVENTDATA();
    SET @EventType = @EventData.value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(50)');
    SET @ObjectName = @EventData.value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(255)');
    SET @ObjectType = @EventData.value('(/EVENT_INSTANCE/ObjectType)[1]', 'NVARCHAR(100)');
    SET @LoginName = @EventData.value('(/EVENT_INSTANCE/LoginName)[1]', 'NVARCHAR(255)');
    SET @TSQLCommand = @EventData.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'NVARCHAR(MAX)');
    SET @HostName = HOST_NAME();

    SET @DefinitionBefore = NULL;
    SET @DefinitionAfter = NULL;
    SET @DefinitionDiff = NULL;

    -------------------------------------------------------
    -- 🔹 Capturar definición anterior (si existía)
    -------------------------------------------------------
    IF @EventType LIKE 'ALTER%' OR @EventType LIKE 'DROP%'
        SELECT @DefinitionBefore = sm.definition
        FROM sys.sql_modules sm
        INNER JOIN sys.objects so ON sm.object_id = so.object_id
        WHERE so.name = @ObjectName;

    -------------------------------------------------------
    -- 🔹 Esperar reintentos para capturar nueva definición
    -------------------------------------------------------
    WHILE @i < 5 AND @DefinitionAfter IS NULL AND @EventType LIKE 'ALTER%' OR @EventType LIKE 'CREATE%'
    BEGIN
        WAITFOR DELAY '00:00:01';
        SELECT @DefinitionAfter = sm.definition
        FROM sys.sql_modules sm
        INNER JOIN sys.objects so ON sm.object_id = so.object_id
        WHERE so.name = @ObjectName;
        SET @i += 1;
    END;

    -------------------------------------------------------
    -- 🔹 Calcular diferencias
    -------------------------------------------------------
    IF @DefinitionBefore IS NOT NULL AND @DefinitionAfter IS NOT NULL
    BEGIN
        DECLARE @Before TABLE(Line NVARCHAR(MAX));
        DECLARE @After TABLE(Line NVARCHAR(MAX));

        INSERT INTO @Before SELECT LTRIM(RTRIM(value)) FROM STRING_SPLIT(@DefinitionBefore, CHAR(10));
        INSERT INTO @After  SELECT LTRIM(RTRIM(value)) FROM STRING_SPLIT(@DefinitionAfter, CHAR(10));

        SELECT @DefinitionDiff = STRING_AGG('+' + a.Line, CHAR(13)+CHAR(10))
        FROM @After a
        WHERE a.Line NOT IN (SELECT Line FROM @Before);

        IF @DefinitionDiff IS NULL OR LEN(@DefinitionDiff) = 0
            SET @DefinitionDiff = '(Sin diferencias detectadas)';
    END
    ELSE
    BEGIN
        IF @DefinitionBefore IS NULL SET @DefinitionBefore = '(No disponible)';
        IF @DefinitionAfter IS NULL SET @DefinitionAfter = '(No disponible)';
        IF @DefinitionDiff IS NULL SET @DefinitionDiff = '(No disponible o sin cambios detectados)';
    END;

    -------------------------------------------------------
    -- 🔹 Registrar auditoría
    -------------------------------------------------------
    INSERT INTO dbo.SP_ChangeLog
    (
        EventType, ObjectName, ObjectType, LoginName, HostName,
        EventDate, DefinitionBefore, DefinitionAfter, DefinitionDiff, TSQLCommand
    )
    VALUES
    (
        @EventType,
        @ObjectName,
        @ObjectType,
        @LoginName,
        @HostName,
        GETDATE(),
        @DefinitionBefore,
        @DefinitionAfter,
        @DefinitionDiff,
        @TSQLCommand
    );
END;
GO