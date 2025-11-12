SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreateReturnReason]

@Description VARCHAR(30)
AS 

BEGIN

IF(EXISTS(SELECT Description FROM ReturnReason WHERE Description = @Description))
BEGIN

SELECT -1

END
ELSE
BEGIN
INSERT INTO [dbo].ReturnReason
           ([Description])
     VALUES
           (@Description)
	
	END

	SELECT @@IDENTITY

	END
GO