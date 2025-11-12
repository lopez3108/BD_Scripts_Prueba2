SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create PROCEDURE [dbo].[sp_DeleteUsersXGroup]
 (
      @UserId int
    )
AS 

BEGIN


DELETE [dbo].[UsersXGroup] WHERE UserId = @UserId




	END


GO