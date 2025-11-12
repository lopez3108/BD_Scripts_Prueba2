SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeletePropertiesBillInsurance]
 (
 @PropertiesBillInsuranceId INT,
		   @CurrentDate DATETIME
    )
AS 

BEGIN

declare @billInsuranceDate DATETIME
set @billInsuranceDate = (SELECT TOP 1 CreationDate FROM [dbo].[PropertiesBillInsurance] WHERE PropertiesBillInsuranceId = @PropertiesBillInsuranceId)

IF(CAST(@billInsuranceDate as date) <> CAST(@CurrentDate as date))
BEGIN

SELECT -1

END
ELSE
BEGIN

DELETE [dbo].[PropertiesBillInsurance]
WHERE PropertiesBillInsuranceId = @PropertiesBillInsuranceId

SELECT @PropertiesBillInsuranceId

END

	END
GO