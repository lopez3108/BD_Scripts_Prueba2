SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_DeleteClient]
 (
	  @ClientId int

    )
AS 

BEGIN

IF(EXISTS(SELECT * FROM Checks WHERE ClientId = @ClientId))
BEGIN

SELECT 2

END
ELSE
BEGIN

DELETE Clientes WHERE ClienteId = @ClientId

SELECT 1


END


	END


GO