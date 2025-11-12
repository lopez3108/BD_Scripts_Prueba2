SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CreateTelephone]
 (
	 @Telephone VARCHAR(12)

    )
AS 

BEGIN

IF(EXISTS(SELECT TOP 1 Telephone FROM Telephones WHERE Telephone = @Telephone))
BEGIN

SELECT -1

END
ELSE
BEGIN

INSERT INTO [dbo].[Telephones]
           ([Telephone])
     VALUES
           (@Telephone)

	END

	SELECT 1

	END
GO