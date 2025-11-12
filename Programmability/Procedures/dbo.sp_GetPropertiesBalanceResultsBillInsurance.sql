SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetPropertiesBalanceResultsBillInsurance]
(@FromDate     DATETIME,
 @ToDate            DATETIME,
 @PropertiesIds         VARCHAR(100)
)
AS
     BEGIN

SELECT        
dbo.PropertiesBillInsurance.PropertiesBillInsuranceId, 
dbo.PropertiesBillInsurance.PropertiesId, 
dbo.PropertiesBillInsurance.Usd, 
dbo.PropertiesBillInsurance.CreationDate, 
dbo.Properties.Name as PropertyName, 
dbo.PropertiesBillInsurance.FromDate, 
dbo.PropertiesBillInsurance.ToDate, 
dbo.ProviderCommissionPaymentTypes.Description as PaymentTypeDescription
FROM            dbo.PropertiesBillInsurance INNER JOIN
                         dbo.Properties ON dbo.PropertiesBillInsurance.PropertiesId = dbo.Properties.PropertiesId INNER JOIN
                         dbo.ProviderCommissionPaymentTypes ON dbo.PropertiesBillInsurance.ProviderCommissionPaymentTypeId = dbo.ProviderCommissionPaymentTypes.ProviderCommissionPaymentTypeId
 WHERE
CAST(PropertiesBillInsurance.CreationDate as DATE) >= CAST(@FromDate as DATE) AND
CAST(PropertiesBillInsurance.CreationDate as DATE) <= CAST(@ToDate as DATE) AND
 dbo.Properties.PropertiesId IN
         (
             SELECT item
             FROM dbo.FN_ListToTableInt(@PropertiesIds)
			 )




       
     END;
GO