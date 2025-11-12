SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetChangeTypeStatus]
AS
     SET NOCOUNT ON;
    BEGIN
        SELECT *
        FROM ChangeTypeStatus;
    END;
GO