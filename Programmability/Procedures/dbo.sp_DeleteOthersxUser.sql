SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteOthersxUser]
@UserId INT
AS
     BEGIN
        
		DELETE FROM [dbo].[OthersxUser]
      WHERE UserId = @UserId


     END;


GO