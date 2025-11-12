SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2025-04-02 JF/6395: Verificar tiempos laborados con dos perfiles en mismo horario


CREATE PROCEDURE [dbo].[sp_HasOpenAdminTimesheetById] 
    @UserId INT, 
    @LoginDate DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 
        FROM TimeSheet
        WHERE UserId = @UserId
        AND CAST(LoginDate AS DATE) = CAST(@LoginDate AS DATE)
        AND AgencyId IS NULL 
        AND LogoutDate IS NULL
    )
    BEGIN
        SELECT CAST(1 AS BIT) AS HasOpenSession; -- Retorna TRUE
    END
    ELSE
    BEGIN
        SELECT CAST(0 AS BIT) AS HasOpenSession; -- Retorna FALSE
    END
END;
GO