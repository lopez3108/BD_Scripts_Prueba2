SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetSuspiciousActivityStatus]

AS
     SET NOCOUNT ON;
    BEGIN
        
		SELECT SuspiciousActivityStatusId, Description FROM SuspiciousActivityStatus





    END;
GO