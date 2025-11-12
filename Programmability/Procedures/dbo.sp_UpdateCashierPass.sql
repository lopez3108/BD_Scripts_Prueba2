SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_UpdateCashierPass]
 (
	  @UserId int,
	  @Pass varchar(50),
	  @LastPasswordChangeDate DATETIME  = NULL

    )
AS

BEGIN


	UPDATE Users
	SET Pass = @Pass, LastPasswordChangeDate = @LastPasswordChangeDate
	WHERE UserId = @UserId

END
GO