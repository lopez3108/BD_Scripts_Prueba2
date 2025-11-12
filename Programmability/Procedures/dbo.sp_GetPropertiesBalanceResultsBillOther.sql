SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetPropertiesBalanceResultsBillOther]
(@FromDate     DATETIME,
 @ToDate            DATETIME,
 @PropertiesIds         VARCHAR(100)
)
AS
     BEGIN

SELECT        
dbo.PropertiesBillOthers.PropertiesBillOtherId, 
dbo.PropertiesBillOthers.PropertiesId, 
dbo.PropertiesBillOthers.Description, 
CASE 
WHEN(dbo.PropertiesBillOthers.IsCredit = 1) THEN
'CREDIT' ELSE
'DEBIT' END AS Type,
dbo.PropertiesBillOthers.IsCredit, 
dbo.PropertiesBillOthers.Usd, 
dbo.PropertiesBillOthers.CreationDate, 
dbo.Properties.Name as PropertyName, 
dbo.Apartments.Number, 
dbo.ProviderCommissionPaymentTypes.Description AS PaymentTypeDescription
FROM            dbo.PropertiesBillOthers INNER JOIN
                         dbo.Properties ON dbo.PropertiesBillOthers.PropertiesId = dbo.Properties.PropertiesId INNER JOIN
                         dbo.ProviderCommissionPaymentTypes ON dbo.PropertiesBillOthers.ProviderCommissionPaymentTypeId = dbo.ProviderCommissionPaymentTypes.ProviderCommissionPaymentTypeId LEFT OUTER JOIN
                         dbo.Apartments ON dbo.PropertiesBillOthers.ApartmentId = dbo.Apartments.ApartmentsId
						 WHERE
CAST(PropertiesBillOthers.CreationDate as DATE) >= CAST(@FromDate as DATE) AND
CAST(PropertiesBillOthers.CreationDate as DATE) <= CAST(@ToDate as DATE) AND
 dbo.Properties.PropertiesId IN
         (
             SELECT item
             FROM dbo.FN_ListToTableInt(@PropertiesIds)
			 )






       
     END;
GO