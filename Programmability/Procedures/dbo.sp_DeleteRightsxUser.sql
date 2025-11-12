SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_DeleteRightsxUser]
 (
      @UserId int
    )
AS 

BEGIN

DELETE RightsxUser WHERE UserId = @UserId

SELECT @UserId

	END


GO