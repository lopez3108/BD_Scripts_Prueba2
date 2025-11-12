SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
Create PROCEDURE [dbo].[sp_GetTimeSheetStatus]
AS
     SET NOCOUNT ON;
    BEGIN
        SELECT *
        FROM TimeSheetStatus;
    END;
GO