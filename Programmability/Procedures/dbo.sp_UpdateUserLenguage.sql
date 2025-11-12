SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_UpdateUserLenguage]
 (
	  @UserId int,
	  @Lenguage int

    )
AS 

BEGIN

UPDATE Users SET Lenguage = @Lenguage WHERE UserId = @UserId

SELECT 1

	END

GO