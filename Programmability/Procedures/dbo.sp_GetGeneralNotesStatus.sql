SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetGeneralNotesStatus]
AS
     SET NOCOUNT ON;
    BEGIN
        SELECT *
        FROM GeneralNotesStatus;
    END;
GO