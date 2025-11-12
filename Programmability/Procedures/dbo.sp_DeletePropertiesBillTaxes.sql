SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeletePropertiesBillTaxes]
 (
 @PropertiesBillTaxesId INT,
		   @CurrentDate DATETIME
    )
AS 

BEGIN

declare @billTaxesDate DATETIME
set @billTaxesDate = (SELECT TOP 1 CreationDate FROM [dbo].[PropertiesBillTaxes] WHERE PropertiesBillTaxesId = @PropertiesBillTaxesId)

IF(CAST(@billTaxesDate as date) <> CAST(@CurrentDate as date))
BEGIN

SELECT -1

END
ELSE
BEGIN

DELETE [dbo].[PropertiesBillTaxes]
WHERE PropertiesBillTaxesId = @PropertiesBillTaxesId

SELECT @PropertiesBillTaxesId

END

	END
GO