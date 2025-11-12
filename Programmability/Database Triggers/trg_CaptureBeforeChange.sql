SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE TRIGGER [trg_CaptureBeforeChange]
ON DATABASE
FOR ALTER_PROCEDURE, DROP_PROCEDURE,
    ALTER_FUNCTION, DROP_FUNCTION,
    ALTER_VIEW, DROP_VIEW,
    ALTER_TRIGGER, DROP_TRIGGER
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @EventData XML, @ObjectName NVARCHAR(255);

    SET @EventData = EVENTDATA();
    SET @ObjectName = @EventData.value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(255)');

    -- Captura la definición actual (antes de ser modificada o eliminada)
    DELETE FROM dbo.SP_ObjectDefinitionCache WHERE ObjectName = @ObjectName;

    INSERT INTO dbo.SP_ObjectDefinitionCache (ObjectName, Definition)
    SELECT so.name, sm.definition
    FROM sys.sql_modules sm
    INNER JOIN sys.objects so ON sm.object_id = so.object_id
    WHERE so.name = @ObjectName;
END;
GO