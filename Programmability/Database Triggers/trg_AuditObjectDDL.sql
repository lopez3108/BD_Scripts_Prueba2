SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE TRIGGER [trg_AuditObjectDDL]
ON DATABASE
FOR CREATE_PROCEDURE, ALTER_PROCEDURE, DROP_PROCEDURE,
    CREATE_FUNCTION, ALTER_FUNCTION, DROP_FUNCTION,
    CREATE_VIEW, ALTER_VIEW, DROP_VIEW,
    CREATE_TRIGGER, ALTER_TRIGGER, DROP_TRIGGER
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE 
        @event XML,
        @EventType NVARCHAR(50),
        @ObjectName NVARCHAR(255),
        @ObjectType NVARCHAR(100),
        @LoginName NVARCHAR(255),
        @HostName NVARCHAR(255),
        @ProgramName NVARCHAR(255),
        @DefinitionBefore NVARCHAR(MAX),
        @DefinitionAfter NVARCHAR(MAX),
        @DefinitionDiff NVARCHAR(MAX);

    SET @event = EVENTDATA();
    SET @EventType = @event.value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(50)');
    SET @ObjectName = @event.value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(255)');
    SET @ObjectType = @event.value('(/EVENT_INSTANCE/ObjectType)[1]', 'NVARCHAR(100)');
    SET @LoginName = ORIGINAL_LOGIN();
    SET @HostName = HOST_NAME();
    SET @ProgramName = APP_NAME();

    -- 🔹 Definición antes del cambio
    SELECT @DefinitionBefore = sm.definition
    FROM sys.sql_modules sm
    INNER JOIN sys.objects so ON sm.object_id = so.object_id
    WHERE so.name = @ObjectName;

    -- 🔹 Espera breve para permitir actualización de metadatos
    WAITFOR DELAY '00:00:00.200';

    -- 🔹 Definición después del cambio
    SELECT @DefinitionAfter = sm.definition
    FROM sys.sql_modules sm
    INNER JOIN sys.objects so ON sm.object_id = so.object_id
    WHERE so.name = @ObjectName;

    IF @DefinitionBefore IS NULL SET @DefinitionBefore = '(No disponible)';
    IF @DefinitionAfter IS NULL SET @DefinitionAfter = '(No disponible)';

    -- 🔹 Generar diferencias básicas (sin subconsultas)
    DECLARE @Before TABLE(Line NVARCHAR(MAX));
    DECLARE @After  TABLE(Line NVARCHAR(MAX));

    INSERT INTO @Before SELECT LTRIM(RTRIM(value)) FROM STRING_SPLIT(@DefinitionBefore, CHAR(10));
    INSERT INTO @After  SELECT LTRIM(RTRIM(value)) FROM STRING_SPLIT(@DefinitionAfter, CHAR(10));

    SELECT @DefinitionDiff = STRING_AGG('+ ' + a.Line, CHAR(13) + CHAR(10))
    FROM @After a
    LEFT JOIN @Before b ON a.Line = b.Line
    WHERE b.Line IS NULL;

    IF @DefinitionDiff IS NULL OR LEN(@DefinitionDiff) = 0
        SET @DefinitionDiff = '(Sin diferencias detectadas)';

    INSERT INTO dbo.SP_ChangeLog
    (
        EventType, ObjectName, ObjectType,
        LoginName, HostName, ProgramName,
        EventDate, DefinitionBefore, DefinitionAfter, DefinitionDiff
    )
    VALUES
    (
        @EventType, @ObjectName, @ObjectType,
        @LoginName, @HostName, @ProgramName,
        GETDATE(), @DefinitionBefore, @DefinitionAfter, @DefinitionDiff
    );
END;
GO