SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Created by jf/24-09-2025 task 6763 Bugs generales del proceso Fee due, ACH date y view contract

CREATE PROCEDURE [dbo].[sp_GetPropertiesBalanceResults] (@FromDate DATETIME,
@ToDate DATETIME,
@PropertiesIds VARCHAR(100))
AS
BEGIN

  SELECT
    dbo.Properties.PropertiesId
   ,dbo.Properties.Name
   ,dbo.Properties.Address
   ,dbo.Properties.Zipcode
   ,dbo.ZipCodes.City
   ,dbo.ZipCodes.State
   ,dbo.ZipCodes.StateAbre
   ,dbo.Properties.PIN
   ,
    -- Total rents
    ISNULL((SELECT
        SUM(rp.UsdPayment)
      FROM RentPayments rp
      INNER JOIN Contract c
        ON c.ContractId = rp.ContractId
      INNER JOIN Apartments a
        ON a.ApartmentsId = c.ApartmentId
      WHERE a.PropertiesId = dbo.Properties.PropertiesId
      AND (
      (
      rp.AchDate IS NOT NULL
      AND CAST(rp.AchDate AS DATE) BETWEEN CAST(@FromDate AS DATE) AND CAST(@ToDate AS DATE)
      )
      OR (
      rp.AchDate IS NULL
      AND CAST(rp.CreationDate AS DATE) BETWEEN CAST(@FromDate AS DATE) AND CAST(@ToDate AS DATE)
      )
      ))
    , 0) AS TotalRents
   ,

    -- Total fee due
    ISNULL((SELECT
        SUM(r.FeeDue)
      FROM RentPayments r
      INNER JOIN Contract c
        ON c.ContractId = r.ContractId
      INNER JOIN Apartments a
        ON a.ApartmentsId = c.ApartmentId
      WHERE a.PropertiesId = dbo.Properties.PropertiesId
      AND (
      (
      r.AchDate IS NOT NULL
      AND CAST(r.AchDate AS DATE) BETWEEN CAST(@FromDate AS DATE) AND CAST(@ToDate AS DATE)
      )
      OR (
      r.AchDate IS NULL
      AND CAST(r.CreationDate AS DATE) BETWEEN CAST(@FromDate AS DATE) AND CAST(@ToDate AS DATE)
      )
      ))
    , 0) AS TotalFeeDue
   ,

    -- Total move-in fee
    ISNULL((SELECT
        SUM(r.MoveInFee)
      FROM RentPayments r
      INNER JOIN Contract c
        ON c.ContractId = r.ContractId
      INNER JOIN Apartments a
        ON a.ApartmentsId = c.ApartmentId
      WHERE a.PropertiesId = dbo.Properties.PropertiesId
      AND (
      (
      r.AchDate IS NOT NULL
      AND CAST(r.AchDate AS DATE) BETWEEN CAST(@FromDate AS DATE) AND CAST(@ToDate AS DATE)
      )
      OR (
      r.AchDate IS NULL
      AND CAST(r.CreationDate AS DATE) BETWEEN CAST(@FromDate AS DATE) AND CAST(@ToDate AS DATE)
      )
      ))
    , 0) AS TotalMoveInFee
   ,

    -- Deposit payments
    ISNULL((SELECT
        SUM(d.Usd)
      FROM DepositFinancingPayments d
      INNER JOIN Contract c
        ON c.ContractId = d.ContractId
      INNER JOIN Apartments a
        ON a.ApartmentsId = c.ApartmentId
      WHERE a.PropertiesId = dbo.Properties.PropertiesId
      AND (
      (
      d.AchDate IS NOT NULL
      AND CAST(d.AchDate AS DATE) BETWEEN CAST(@FromDate AS DATE) AND CAST(@ToDate AS DATE)
      )
      OR (
      d.AchDate IS NULL
      AND CAST(d.CreationDate AS DATE) BETWEEN CAST(@FromDate AS DATE) AND CAST(@ToDate AS DATE)
      )
      ))
    , 0) AS TotalDeposit
   ,
    -- Deposit refund
    ISNULL([dbo].[fn_GetPropertiesDepositRefund](dbo.Properties.PropertiesId, @FromDate, @ToDate), 0) AS TotalDepositRefund
   ,
    -- Total Bill taxes
    ISNULL((SELECT
        SUM(Usd)
      FROM PropertiesBillTaxes
      WHERE PropertiesBillTaxes.PropertiesId = dbo.Properties.PropertiesId
      AND CAST(PropertiesBillTaxes.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
      AND CAST(PropertiesBillTaxes.CreationDate AS DATE) <= CAST(@ToDate AS DATE))
    , 0) AS TotalBillTaxes
   ,
    -- Total Bill water
    ISNULL((SELECT
        SUM(Usd)
      FROM PropertiesBillWater
      WHERE PropertiesBillWater.PropertiesId = dbo.Properties.PropertiesId
      AND CAST(PropertiesBillWater.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
      AND CAST(PropertiesBillWater.CreationDate AS DATE) <= CAST(@ToDate AS DATE))
    , 0) AS TotalBillWater
   ,
    -- Total Bill insurance
    ISNULL((SELECT
        SUM(Usd)
      FROM PropertiesBillInsurance
      WHERE PropertiesBillInsurance.PropertiesId = dbo.Properties.PropertiesId
      AND CAST(PropertiesBillInsurance.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
      AND CAST(PropertiesBillInsurance.CreationDate AS DATE) <= CAST(@ToDate AS DATE))
    , 0) AS TotalBillInsurance
   ,
    -- Total Bill Labor
    ISNULL((SELECT
        SUM(Usd)
      FROM PropertiesBillLabor
      WHERE PropertiesBillLabor.PropertiesId = dbo.Properties.PropertiesId
      AND CAST(PropertiesBillLabor.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
      AND CAST(PropertiesBillLabor.CreationDate AS DATE) <= CAST(@ToDate AS DATE))
    , 0) AS TotalBillLabor
   ,
    -- Total Bill other
    ISNULL((SELECT
        SUM(
        CASE
          WHEN IsCredit = 1 THEN Usd
          ELSE (Usd * -1)
        END)
      FROM PropertiesBillOthers
      WHERE PropertiesBillOthers.PropertiesId = dbo.Properties.PropertiesId
      AND CAST(PropertiesBillOthers.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
      AND CAST(PropertiesBillOthers.CreationDate AS DATE) <= CAST(@ToDate AS DATE))
    , 0) AS TotalBillOther
  FROM dbo.Properties
  INNER JOIN dbo.ZipCodes
    ON dbo.Properties.Zipcode = dbo.ZipCodes.ZipCode
  WHERE dbo.Properties.PropertiesId IN (SELECT
      item
    FROM dbo.FN_ListToTableInt(@PropertiesIds))




END;



GO