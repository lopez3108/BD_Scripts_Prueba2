SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetPropertiesBalanceResultsBillTaxes]
(@FromDate     DATETIME,
 @ToDate            DATETIME,
 @PropertiesIds         VARCHAR(100)
)
AS
     BEGIN


SELECT        
dbo.PropertiesBillTaxes.PropertiesBillTaxesId, 
dbo.PropertiesBillTaxes.PropertiesId, 
dbo.PropertiesBillTaxes.CreationDate, 
dbo.Properties.Name as PropertyName, 
dbo.PropertiesBillTaxes.Usd, 
dbo.ProviderCommissionPaymentTypes.Description AS PaymentTypeDescription, 
dbo.PropertiesBillTaxes.FromDate, 
dbo.PropertiesBillTaxes.ToDate
FROM            dbo.PropertiesBillTaxes INNER JOIN
                         dbo.Properties ON dbo.PropertiesBillTaxes.PropertiesId = dbo.Properties.PropertiesId INNER JOIN
                         dbo.ProviderCommissionPaymentTypes ON dbo.PropertiesBillTaxes.ProviderCommissionPaymentTypeId = dbo.ProviderCommissionPaymentTypes.ProviderCommissionPaymentTypeId
						  WHERE
CAST(PropertiesBillTaxes.CreationDate as DATE) >= CAST(@FromDate as DATE) AND
CAST(PropertiesBillTaxes.CreationDate as DATE) <= CAST(@ToDate as DATE) AND
 dbo.Properties.PropertiesId IN
         (
             SELECT item
             FROM dbo.FN_ListToTableInt(@PropertiesIds)
			 )


       
     END;
GO