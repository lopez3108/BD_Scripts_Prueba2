SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetPropertiesFinancialCost]
(
 @PropertiesIds         VARCHAR(100),
 @Date DATETIME
)
AS
     BEGIN

	

SELECT        
dbo.Properties.PropertiesId, 
dbo.Properties.Name, 
dbo.Properties.Address, 
dbo.Properties.Zipcode, 
dbo.ZipCodes.City, 
dbo.ZipCodes.State, 
dbo.ZipCodes.StateAbre,
dbo.Properties.Pin,
dbo.Properties.PropertyValue,
dbo.Properties.PurchaseDate,
-- Total rents
ISNULL((SELECT SUM(Usd) FROM RentPayments INNER JOIN 
Contract ON Contract.ContractId = RentPayments.ContractId INNER JOIN
Apartments ON Apartments.ApartmentsId = Contract.ApartmentId  WHERE
Apartments.PropertiesId = dbo.Properties.PropertiesId AND
CAST(RentPayments.CreationDate as DATE) >= CAST((SELECT TOP 1 PurchaseDate FROm Properties p WHERE p.PropertiesId = dbo.Properties.PropertiesId) as DATE) AND
CAST(RentPayments.CreationDate as DATE) <= CAST(@Date as DATE)),0) as TotalRents,
-- Total Bill taxes
ISNULL((SELECT SUM(Usd) FROM PropertiesBillTaxes  WHERE
PropertiesBillTaxes.PropertiesId = dbo.Properties.PropertiesId AND
CAST(PropertiesBillTaxes.CreationDate as DATE) >= CAST((SELECT TOP 1 PurchaseDate FROm Properties p WHERE p.PropertiesId = dbo.Properties.PropertiesId) as DATE) AND
CAST(PropertiesBillTaxes.CreationDate as DATE) <= CAST(@Date as DATE)),0) as TotalBillTaxes,
-- Total Bill water
ISNULL((SELECT SUM(Usd) FROM PropertiesBillWater  WHERE
PropertiesBillWater.PropertiesId = dbo.Properties.PropertiesId AND
CAST(PropertiesBillWater.CreationDate as DATE) >= CAST((SELECT TOP 1 PurchaseDate FROm Properties p WHERE p.PropertiesId = dbo.Properties.PropertiesId) as DATE) AND
CAST(PropertiesBillWater.CreationDate as DATE) <= CAST(@Date as DATE)),0) as TotalBillWater,
-- Total Bill insurance
ISNULL((SELECT SUM(Usd) FROM PropertiesBillInsurance  WHERE
PropertiesBillInsurance.PropertiesId = dbo.Properties.PropertiesId AND
CAST(PropertiesBillInsurance.CreationDate as DATE) >= CAST((SELECT TOP 1 PurchaseDate FROm Properties p WHERE p.PropertiesId = dbo.Properties.PropertiesId) as DATE) AND
CAST(PropertiesBillInsurance.CreationDate as DATE) <= CAST(@Date as DATE)),0) as TotalBillInsurance,
-- Total Bill Labor
ISNULL((SELECT SUM(Usd) FROM PropertiesBillLabor  WHERE
PropertiesBillLabor.PropertiesId = dbo.Properties.PropertiesId AND
CAST(PropertiesBillLabor.CreationDate as DATE) >= CAST((SELECT TOP 1 PurchaseDate FROm Properties p WHERE p.PropertiesId = dbo.Properties.PropertiesId) as DATE) AND
CAST(PropertiesBillLabor.CreationDate as DATE) <= CAST(@Date as DATE)),0) as TotalBillLabor,
-- Total Bill other
ISNULL((SELECT SUM(
CASE 
WHEN IsCredit = 1 THEN
Usd ELSE
(Usd * -1)
END)
FROM PropertiesBillOthers  WHERE
PropertiesBillOthers.PropertiesId = dbo.Properties.PropertiesId AND
CAST(PropertiesBillOthers.CreationDate as DATE) >= CAST((SELECT TOP 1 PurchaseDate FROm Properties p WHERE p.PropertiesId = dbo.Properties.PropertiesId) as DATE) AND
CAST(PropertiesBillOthers.CreationDate as DATE) <= CAST(@Date as DATE)),0) as TotalBillOther
FROM            dbo.Properties INNER JOIN
                         dbo.ZipCodes ON dbo.Properties.Zipcode = dbo.ZipCodes.ZipCode
WHERE dbo.Properties.PropertiesId IN
         (
             SELECT item
             FROM dbo.FN_ListToTableInt(@PropertiesIds)
         )



       
     END;
GO