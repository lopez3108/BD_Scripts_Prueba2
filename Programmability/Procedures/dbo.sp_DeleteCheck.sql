SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_DeleteCheck]
 (
	  @CheckId int

    )
AS 

BEGIN


DELETE Checks WHERE CheckId = @CheckId

SELECT 1




	END


GO