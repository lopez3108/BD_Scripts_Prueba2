SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetPropertiesBalanceResultsBillLabor]
(@FromDate     DATETIME,
 @ToDate            DATETIME,
 @PropertiesIds         VARCHAR(100)
)
AS
     BEGIN

SELECT        dbo.PropertiesBillLabor.PropertiesBillLaborId, dbo.PropertiesBillLabor.PropertiesId, dbo.PropertiesBillLabor.Name, dbo.PropertiesBillLabor.Usd, dbo.PropertiesBillLabor.CreationDate, dbo.Properties.Name AS PropertyName, 
                         dbo.Apartments.Number, dbo.ProviderCommissionPaymentTypes.Description AS PaymentTypeDescription
FROM            dbo.PropertiesBillLabor INNER JOIN
                         dbo.Properties ON dbo.PropertiesBillLabor.PropertiesId = dbo.Properties.PropertiesId INNER JOIN
                         dbo.ProviderCommissionPaymentTypes ON dbo.PropertiesBillLabor.ProviderCommissionPaymentTypeId = dbo.ProviderCommissionPaymentTypes.ProviderCommissionPaymentTypeId LEFT OUTER JOIN
                         dbo.Apartments ON dbo.PropertiesBillLabor.ApartmentId = dbo.Apartments.ApartmentsId
						 WHERE
CAST(PropertiesBillLabor.CreationDate as DATE) >= CAST(@FromDate as DATE) AND
CAST(PropertiesBillLabor.CreationDate as DATE) <= CAST(@ToDate as DATE) AND
 dbo.Properties.PropertiesId IN
         (
             SELECT item
             FROM dbo.FN_ListToTableInt(@PropertiesIds)
			 )




       
     END;
GO