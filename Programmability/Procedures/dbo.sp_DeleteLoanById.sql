SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteLoanById] @UserXPassId INT
AS
    BEGIN
        DELETE FROM dbo.AdminsXPass
        WHERE UserXPassId = @UserXPassId;
    END;
GO