SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_UpdateUserPass]
 (
      @UserId int,
	  @Pass varchar(50)
    )
AS 

BEGIN


UPDATE [dbo].[Users]
		SET [Pass] = @Pass
		WHERE UserId = @UserId

		   SELECT @UserId


	END

GO