SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_DeleteAgenciesxUser]
 (
      @UserId int
    )
AS 

BEGIN


DELETE [dbo].[AgenciesxUser] WHERE UserId = @UserId

SELECT 1


	END


GO