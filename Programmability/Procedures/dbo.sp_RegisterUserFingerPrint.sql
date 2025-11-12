SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_RegisterUserFingerPrint]
 (
      @UserId INT,
	  @FingerPrint varchar(max)
    )
AS 

BEGIN

UPDATE Users SET FingerPrintTemplate = @FingerPrint WHERE UserId = @UserId
SELECT CAST(1 as BIT)

	END
GO