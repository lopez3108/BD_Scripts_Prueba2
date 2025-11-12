SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteUserPass](@UserPassId INT)
AS
     BEGIN
         DELETE UserPass
         WHERE UserPassId = @UserPassId;
         SELECT 1;
     END;
GO