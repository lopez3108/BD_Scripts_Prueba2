SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetPropertiesBalanceResultsBillWater]
(@FromDate     DATETIME,
 @ToDate            DATETIME,
 @PropertiesIds         VARCHAR(100)
)
AS
     BEGIN

SELECT        dbo.PropertiesBillWater.PropertiesBillWaterId, dbo.PropertiesBillWater.PropertiesId, dbo.PropertiesBillWater.CreationDate, dbo.Properties.Name AS PropertyName, dbo.PropertiesBillWater.Usd, 
                         dbo.ProviderCommissionPaymentTypes.Description as PaymentTypeDescription,
						 dbo.PropertiesBillWater.Gallons, dbo.PropertiesBillWater.FromDate, dbo.PropertiesBillWater.ToDate
FROM            dbo.PropertiesBillWater INNER JOIN
                         dbo.Properties ON dbo.PropertiesBillWater.PropertiesId = dbo.Properties.PropertiesId INNER JOIN
                         dbo.ProviderCommissionPaymentTypes ON dbo.PropertiesBillWater.ProviderCommissionPaymentTypeId = dbo.ProviderCommissionPaymentTypes.ProviderCommissionPaymentTypeId
						 WHERE
CAST(PropertiesBillWater.CreationDate as DATE) >= CAST(@FromDate as DATE) AND
CAST(PropertiesBillWater.CreationDate as DATE) <= CAST(@ToDate as DATE) AND
 dbo.Properties.PropertiesId IN
         (
             SELECT item
             FROM dbo.FN_ListToTableInt(@PropertiesIds)
			 )




       
     END;
GO