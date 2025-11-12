SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Last update by jt/11-06-2024 task 5797  Valores comisión payroll - tax checks  no coinciden
--Last update by jt/11-06-2024 task 5795  Valores comisión ventra no coincide 
--Last update by jt/18-05-2024 task 5875 Error en cálculo comisiones money orders 
--Last update by JF/03-06-2024 task 5883 Commission payment adjustment returned checks 

CREATE PROCEDURE [dbo].[sp_GetProviderMontlyCommissionBalance] (@ProviderId INT = NULL,
@AgencyId INT,
@Month INT,
@Year INT,
@ProviderTypeCode VARCHAR(4))
AS
BEGIN
  IF (@ProviderTypeCode = 'C02')
  BEGIN

    -- MoneyTransfers
    DECLARE @moneyOrders DECIMAL(18, 2);
    SET @moneyOrders = ISNULL((SELECT
        ABS(SUM(Q.Suma))
      FROM (SELECT
          --Formula = total transactions money order fee  - provider money order commission
          (SUM(ISNULL(dbo.MoneyTransfers.TransactionsNumberMoneyOrders, 0)) *
          ((ISNULL(dbo.MoneyTransfers.MoneyOrderFee, 0))
          )) -
          (SUM(ISNULL(dbo.MoneyTransfers.TransactionsNumberMoneyOrders, 0))
          * ((ISNULL(dbo.MoneyTransfers.ProviderMoneyCommission, 0)))) Suma
        FROM dbo.MoneyTransfers
        RIGHT JOIN dbo.Providers
          ON MoneyTransfers.TransactionsNumberMoneyOrders > 0
          AND dbo.MoneyTransfers.ProviderId = dbo.Providers.ProviderId
        --AND dbo.Providers.MoneyOrderService = 1
        INNER JOIN ProviderTypes
          ON ProviderTypes.ProviderTypeId = dbo.Providers.ProviderTypeId
        WHERE dbo.MoneyTransfers.AgencyId = @AgencyId
        AND ProviderTypes.Code = 'C02'
        AND dbo.Providers.ProviderId = @ProviderId
        --Esto se comenta el día 13 - dic - 2022 por ddcisión de Jorge ya según él, las comisiones para pagar solo deben aparecer en el mes en que fueron los moviemitnos
        --Relacionado a la tarea  4623
        --AND (dbo.MoneyTransfers.CreationDate IS NOT NULL
        --     OR CAST(DATEPART(month, dbo.MoneyTransfers.CreationDate) AS INT) = @Month)
        --AND (dbo.MoneyTransfers.CreationDate IS NOT NULL
        --     OR CAST(DATEPART(year, dbo.MoneyTransfers.CreationDate) AS INT) = @Year)
        AND (CAST(DATEPART(MONTH, dbo.MoneyTransfers.CreationDate) AS INT) = @Month)
        AND (CAST(DATEPART(YEAR, dbo.MoneyTransfers.CreationDate) AS INT) = @Year)
        GROUP BY dbo.MoneyTransfers.MoneyOrderFee
                ,dbo.MoneyTransfers.ProviderMoneyCommission) AS Q)
    , 0);
    SELECT
      @moneyOrders;
  END;
  ELSE
  IF (@ProviderTypeCode = 'C03')
  BEGIN

    -- Checks
    DECLARE @checks DECIMAL(18, 2);
    --Commented in task 5797
    --    SET @checks = (SELECT 
    --        ISNULL(SUM(Amount * Fee / 100), 0)
    --      FROM ChecksEls
    --      INNER JOIN ProviderTypes
    --        ON ProviderTypes.ProviderTypeId = ChecksEls.ProviderTypeId
    --      INNER JOIN Providers
    --        ON Providers.ProviderTypeId = ProviderTypes.ProviderTypeId
    --      WHERE AgencyId = @AgencyId
    --      AND ProviderTypes.Code = 'C03'
    --      AND CAST(DATEPART(MONTH, CreationDate) AS INT) = @Month
    --      AND CAST(DATEPART(YEAR, CreationDate) AS INT) = @Year);

    SET @checks = ISNULL((--Task 5797
      SELECT
        SUM(CAST(ISNULL(p.Commission, 0) AS DECIMAL(18, 2)))
      FROM (SELECT
          CAST(ISNULL(Q.Commission, 0) AS DECIMAL(18, 2)) AS Commission
        FROM (SELECT
            ISNULL(SUM(t.Commission), 0) AS Commission
          FROM (SELECT
              CAST(ChecksEls.CreationDate AS DATE) AS CreationDate
             ,ISNULL((dbo.ChecksEls.Amount * dbo.ChecksEls.Fee / 100), 0) Commission
            FROM ChecksEls
            INNER JOIN ProviderTypes
              ON ProviderTypes.ProviderTypeId = ChecksEls.ProviderTypeId
            INNER JOIN Providers
              ON Providers.ProviderTypeId = ProviderTypes.ProviderTypeId
            WHERE AgencyId = @AgencyId
            AND ProviderTypes.Code = 'C03'
            AND CAST(DATEPART(MONTH, CreationDate) AS INT) = @Month
            AND CAST(DATEPART(YEAR, CreationDate) AS INT) = @Year) t
          GROUP BY t.CreationDate
        --        , t.Type, t.Description
        ) AS Q) AS p),0);
    SELECT
      @checks AS Fee
    ;
  END;
  ELSE
  IF (@ProviderTypeCode = 'C04')
  BEGIN

    -- Checks
    DECLARE @checks4 DECIMAL(18, 2);
    SET @checks4 = ISNULL((--Task 5797
      SELECT
        SUM(CAST(ISNULL(p.Commission, 0) AS DECIMAL(18, 2)))
      FROM (SELECT
          CAST(ISNULL(Q.Commission, 0) AS DECIMAL(18, 2)) AS Commission
        FROM (SELECT
            ISNULL(SUM(t.Commission), 0) AS Commission
          FROM (SELECT
              CAST(ChecksEls.CreationDate AS DATE) AS CreationDate
             ,ISNULL((dbo.ChecksEls.Amount * dbo.ChecksEls.Fee / 100), 0) Commission
            FROM ChecksEls
            INNER JOIN ProviderTypes
              ON ProviderTypes.ProviderTypeId = ChecksEls.ProviderTypeId
            INNER JOIN Providers
              ON Providers.ProviderTypeId = ProviderTypes.ProviderTypeId
            WHERE AgencyId = @AgencyId
            AND ProviderTypes.Code = 'C04'
            AND CAST(DATEPART(MONTH, CreationDate) AS INT) = @Month
            AND CAST(DATEPART(YEAR, CreationDate) AS INT) = @Year) t
          GROUP BY t.CreationDate
        --        , t.Type, t.Description
        ) AS Q) AS p),0);
    SELECT
      @checks4 AS Fee;
  END;
  ELSE
  IF (@ProviderTypeCode = 'C01')
  BEGIN

    -- Bill payments
    DECLARE @bill DECIMAL(18, 2);
    SET @bill =
    ISNULL((SELECT
        SUM(ISNULL(Commission, 0))
      FROM dbo.Daily
      INNER JOIN dbo.Cashiers
        ON dbo.Cashiers.CashierId = dbo.Daily.CashierId
      INNER JOIN dbo.BillPayments
        ON dbo.Daily.AgencyId = dbo.BillPayments.AgencyId
        AND CAST(BillPayments.CreationDate AS DATE) = CAST(Daily.CreationDate AS DATE)
        AND dbo.Cashiers.UserId = BillPayments.CreatedBy
      WHERE dbo.Daily.AgencyId = @AgencyId
      AND CAST(DATEPART(MONTH, dbo.Daily.CreationDate) AS INT) = @Month
      AND CAST(DATEPART(YEAR, dbo.Daily.CreationDate) AS INT) = @Year
      AND dbo.Daily.ClosedOn IS NOT NULL
      AND dbo.BillPayments.ProviderId = @ProviderId)
    , 0);
    SELECT
      @bill AS Fee;
  END;
  ELSE
  IF (@ProviderTypeCode = 'C06')
  BEGIN

    -- Cancellations
    DECLARE @cacellations DECIMAL(18, 2);
    SET @cacellations = ISNULL((SELECT
        ISNULL(SUM(Fee), 0)
      FROM Cancellations
      INNER JOIN CancellationStatus
        ON CancellationStatus.CancellationStatusId = Cancellations.FinalStatusId
      WHERE AgencyId = @AgencyId
      AND CAST(DATEPART(MONTH, RefundDate) AS INT) = @Month
      AND CAST(DATEPART(YEAR, RefundDate) AS INT) = @Year
      AND CancellationStatus.Code = 'C01'
      AND (RefundFee IS NULL
      OR RefundFee = 0)),0);
    SET @cacellations = @cacellations * -1;
    SELECT
      @cacellations AS Fee;
  END;
  ELSE
  IF (@ProviderTypeCode = 'C07')
  BEGIN

    -- Others
    DECLARE @others DECIMAL(18, 2);
    SET @others = ISNULL((SELECT
        SUM(USD)
      FROM OthersDetails
      WHERE AgencyId = @AgencyId
      AND CAST(DATEPART(MONTH, CreationDate) AS INT) = @Month
      AND CAST(DATEPART(YEAR, CreationDate) AS INT) = @Year),0);
    SELECT
      @others AS Fee;
  END;
  ELSE
  IF (@ProviderTypeCode = 'C08')
  BEGIN

    -- Returned checks
    DECLARE @returnedchecks DECIMAL(18, 2);
    SET @returnedchecks = ISNULL((
      --                     SELECT SUM(Fee) - SUM(ProviderFee)-- // cambio a nueva operacion 5446
      SELECT
        ISNULL(SUM(Fee) - SUM(ProviderFee), 0)
      --        SUM(Usd + Fee) - SUM(Usd + ProviderFee) -- Se cambia por SUM(Fee) - SUM(ProviderFee) en relacion a la tarea 5883

      FROM ReturnedCheck
      INNER JOIN ReturnStatus
        ON ReturnedCheck.StatusId = ReturnStatus.ReturnStatusId
      WHERE ReturnedAgencyId = @AgencyId
      AND CAST(DATEPART(MONTH, dbo.fn_GetReturnCheckPaidDate(ReturnedCheckId)) AS INT) = @Month
      AND CAST(DATEPART(YEAR, dbo.fn_GetReturnCheckPaidDate(ReturnedCheckId)) AS INT) = @Year
      AND ReturnStatus.Code = 'C02'),0);
    SELECT
      @returnedchecks AS Fee;
  END;
  ELSE
  IF (@ProviderTypeCode = 'C12')
  BEGIN

    -- Phones
    DECLARE @phone DECIMAL(18, 2);
    SET @phone = ISNULL((SELECT
        ISNULL(SUM(SellingValue - PurchaseValue), 0)
      FROM PhoneSales
      INNER JOIN InventoryByAgency
        ON InventoryByAgency.InventoryByAgencyId = PhoneSales.InventoryByAgencyId
      WHERE InventoryByAgency.AgencyId = @AgencyId
      AND CAST(DATEPART(MONTH, CreationDate) AS INT) = @Month
      AND CAST(DATEPART(YEAR, CreationDate) AS INT) = @Year),0);
    SELECT
      @phone AS Fee;
  END;
  ELSE
  IF (@ProviderTypeCode = 'C13')
  BEGIN

    -- Lendify  


    DECLARE @lendify INT;
    SET @lendify = ISNULL((SELECT
        SUM(ComissionCashier)
      FROM Lendify
      WHERE AprovedDate IS NOT NULL
      AND CAST(DATEPART(MONTH, AprovedDate) AS INT) = @Month
      AND CAST(DATEPART(YEAR, AprovedDate) AS INT) = @Year
      AND AgencyId = @AgencyId),0);
    SELECT
      @lendify AS Fee;
  END;
  ELSE
  IF (@ProviderTypeCode = 'C15')
  BEGIN

    -- Notary
    DECLARE @notary DECIMAL(18, 2);
    SET @notary = ISNULL((SELECT
        SUM(USD)
      FROM Notary
      WHERE AgencyId = @AgencyId
      AND CAST(DATEPART(MONTH, CreationDate) AS INT) = @Month
      AND CAST(DATEPART(YEAR, CreationDate) AS INT) = @Year),0);
    SELECT
      @notary AS Fee;
  END;
  ELSE
  --         IF(@ProviderTypeCode = 'C10')
  --             BEGIN
  --
  ---- ELS Manual
  --                 DECLARE @elsmanual DECIMAL(18, 2);
  --                 SET @elsmanual =
  --                 (
  --                     SELECT SUM(ISNULL((((T.USD + ISNULL(T.Fee1, 0) + ABS(ISNULL(t.PlateTypePersonalizedFee, 0)))) - ABS(ABS(ISNULL(t.MOILDOR, 0)) + ABS(ISNULL(t.FeeILDOR, 0)) + ABS(ISNULL(t.FeeILSOS, 0)) + ABS(ISNULL(t.MOLSOS, 0)) + ABS(ISNULL(t.FeeOther, 0)) + ABS(ISNULL(t.MOOther, 0)) + ABS(ISNULL(t.RunnerService, 0)))), 0))
  --                     FROM TITLES t
  --                          INNER JOIN ProcessTypes pt ON t.ProcessTypeId = pt.ProcessTypeId
  --                          INNER JOIN DeliveryTypes dt ON t.DeliveryTypeId = dt.DeliveryTypeId
  --                          INNER JOIN PlateTypes pts ON t.PlateTypeId = pts.PlateTypeId
  --                          INNER JOIN Users us ON t.CreatedBy = us.UserId
  --                          LEFT JOIN PlateTypesPersonalized ptp ON t.PlateTypePersonalizedId = ptp.PlateTypePersonalizedId
  --                          LEFT JOIN Users usu ON t.UpdatedBy = usu.UserId
  --                          LEFT JOIN ProcessStatus ps ON t.ProcessStatusId = ps.ProcessStatusId
  --                     WHERE t.AgencyId = @AgencyId
  --                           AND CAST(DATEPART(month, t.CreationDate) AS INT) = @Month
  --                           AND CAST(DATEPART(year, t.CreationDate) AS INT) = @Year
  --                           AND t.ProcessAuto = 0
  --                 );
  --                 SELECT @elsmanual;
  --         END
  -- Ventra;
  -- ELSE
  IF (@ProviderTypeCode = 'C20')
  BEGIN

    -- Get reloads
    DECLARE @ventracommission DECIMAL(18, 2);
    SET @ventracommission = ISNULL((SELECT --5795 FIX ERROR IN CALCULATION 
        SUM(ISNULL(p.Commission, 0))
      FROM (SELECT
          CAST(ISNULL(Q.Commission, 0) AS DECIMAL(18, 2)) AS Commission
        FROM (SELECT
            ISNULL(SUM(t.Commission), 0) AS Commission
          FROM (SELECT
              CAST(CreationDate AS DATE) AS CreationDate
             ,(ISNULL(dbo.Ventra.ReloadUsd, 0) * ISNULL(dbo.Ventra.Commission, 0) / 100) Commission
            FROM dbo.Ventra
            WHERE dbo.Ventra.AgencyId = @AgencyId
            AND CAST(DATEPART(MONTH, dbo.Ventra.CreationDate) AS INT) = @Month
            AND CAST(DATEPART(YEAR, dbo.Ventra.CreationDate) AS INT) = @Year) t
          GROUP BY t.CreationDate) AS Q) AS p),0);

    SELECT
      @ventracommission AS Fee;
  END
  -- Surplus;
  ELSE
  IF (@ProviderTypeCode = 'C21')
  BEGIN
    DECLARE @surplus DECIMAL(18, 2);
    SET @surplus = ISNULL((SELECT
        SUM(Surplus)
      FROM dbo.Daily d
      WHERE d.AgencyId = @AgencyId
      AND CAST(DATEPART(MONTH, d.CreationDate) AS INT) = @Month
      AND CAST(DATEPART(YEAR, d.CreationDate) AS INT) = @Year),0);
    SELECT
      @surplus AS Fee;
  END
  -- Headphones and chargers;
  ELSE
  IF (@ProviderTypeCode = 'C22')
  BEGIN

    -- Headphones
    DECLARE @headphonecost DECIMAL(18, 2);
    SET @headphonecost = ISNULL((SELECT
        SUM(CostHeadPhones * HeadphonesQuantity)
      FROM dbo.HeadphonesAndChargers d
      WHERE d.AgencyId = @AgencyId
      AND CAST(DATEPART(MONTH, d.CreationDate) AS INT) = @Month
      AND CAST(DATEPART(YEAR, d.CreationDate) AS INT) = @Year),0);
    DECLARE @headphonesusd DECIMAL(18, 2);
    SET @headphonesusd = ISNULL((SELECT
        SUM(HeadphonesUsd)
      FROM dbo.HeadphonesAndChargers d
      WHERE d.AgencyId = @AgencyId
      AND CAST(DATEPART(MONTH, d.CreationDate) AS INT) = @Month
      AND CAST(DATEPART(YEAR, d.CreationDate) AS INT) = @Year),0);
    SET @headphonesusd = @headphonesusd - @headphonecost;

    -- Chargers
    DECLARE @chargercost DECIMAL(18, 2);
    SET @chargercost = ISNULL((SELECT
        SUM(ChargersQuantity * CostChargers)
      FROM dbo.HeadphonesAndChargers d
      WHERE d.AgencyId = @AgencyId
      AND CAST(DATEPART(MONTH, d.CreationDate) AS INT) = @Month
      AND CAST(DATEPART(YEAR, d.CreationDate) AS INT) = @Year),0);
    DECLARE @chargersusd DECIMAL(18, 2);
    SET @chargersusd = ISNULL((SELECT
        SUM(ChargersUsd)
      FROM dbo.HeadphonesAndChargers d
      WHERE d.AgencyId = @AgencyId
      AND CAST(DATEPART(MONTH, d.CreationDate) AS INT) = @Month
      AND CAST(DATEPART(YEAR, d.CreationDate) AS INT) = @Year),0);
    SET @chargersusd = @chargersusd - @chargercost;
    SELECT
      @chargersusd + @headphonesusd AS Fee;
  END
  -- Phone cards;
  ELSE
  IF (@ProviderTypeCode = 'C23')
  BEGIN
    DECLARE @phonecommission DECIMAL(18, 2);
    SET @phonecommission = ISNULL((SELECT
        SUM(ISNULL((ISNULL(dbo.PhoneCards.PhoneCardsUsd, 0) * ISNULL(dbo.PhoneCards.Commission, 0) / 100), 0)) AS Commission
      FROM dbo.PhoneCards
      WHERE dbo.PhoneCards.AgencyId = @AgencyId
      AND CAST(DATEPART(MONTH, dbo.PhoneCards.CreationDate) AS INT) = @Month
      AND CAST(DATEPART(YEAR, dbo.PhoneCards.CreationDate) AS INT) = @Year),0);
    SELECT
      @phonecommission AS Fee;
  END;
  ELSE
  IF (@ProviderTypeCode = 'C05')
  BEGIN

    --ELS

    -- City stickers
    DECLARE @citysticker DECIMAL(18, 2);
    SET @citysticker = ISNULL((SELECT
        SUM(Fee1) - SUM(FeeEls)
      FROM [dbo].[CityStickers]
      WHERE AgencyId = @AgencyId
      AND CAST(DATEPART(MONTH, CreationDate) AS INT) = @Month
      AND CAST(DATEPART(YEAR, CreationDate) AS INT) = @Year),0);

    -- Country taxes
    DECLARE @countrytaxes DECIMAL(18, 2);
    SET @countrytaxes = ISNULL((SELECT
        SUM(Fee1) - SUM(FeeEls)
      FROM [dbo].[CountryTaxes]
      WHERE AgencyId = @AgencyId
      AND CAST(DATEPART(MONTH, CreationDate) AS INT) = @Month
      AND CAST(DATEPART(YEAR, CreationDate) AS INT) = @Year),0);

    -- Parking ticket card
    DECLARE @parkingcard DECIMAL(18, 2);
    SET @parkingcard = ISNULL((SELECT
        SUM(Fee2)
      FROM [dbo].[ParkingTicketsCards]
      WHERE AgencyId = @AgencyId
      AND CAST(DATEPART(MONTH, CreationDate) AS INT) = @Month
      AND CAST(DATEPART(YEAR, CreationDate) AS INT) = @Year),0);

    -- Parking ticket els
    DECLARE @parkingels DECIMAL(18, 2);
    DECLARE @elsFee DECIMAL(18, 2);
    --SET @elsFee = (SELECT TOP 1 ISNULL(FeeELS,0) FROM ProvidersELS WHERE Code = 'C06')
    SET @parkingels = ISNULL((SELECT
        SUM(Fee1) - SUM(FeeEls)
      FROM [dbo].[ParkingTickets]
      WHERE AgencyId = @AgencyId
      AND CAST(DATEPART(MONTH, CreationDate) AS INT) = @Month
      AND CAST(DATEPART(YEAR, CreationDate) AS INT) = @Year),0);

    -- Plate sticker
    DECLARE @platesticker DECIMAL(18, 2);
    SET @platesticker = ISNULL((SELECT
        SUM(Fee1) - SUM(FeeEls)
      FROM [dbo].[PlateStickers]
      WHERE AgencyId = @AgencyId
      AND CAST(DATEPART(MONTH, CreationDate) AS INT) = @Month
      AND CAST(DATEPART(YEAR, CreationDate) AS INT) = @Year),0);

    -- Title inquiry
    DECLARE @inquiry DECIMAL(18, 2);
    SET @inquiry = ISNULL((SELECT
        SUM(Fee1) - SUM(FeeEls)
      FROM TitleInquiry
      WHERE AgencyId = @AgencyId
      AND CAST(DATEPART(MONTH, CreationDate) AS INT) = @Month
      AND CAST(DATEPART(YEAR, CreationDate) AS INT) = @Year),0);

    -- Titles
    DECLARE @titles DECIMAL(18, 2);
    SET @titles = ISNULL((SELECT
        SUM(Fee1) - SUM(FeeEls)
      FROM Titles
      WHERE AgencyId = @AgencyId
      AND CAST(DATEPART(MONTH, CreationDate) AS INT) = @Month
      AND CAST(DATEPART(YEAR, CreationDate) AS INT) = @Year
      AND ProcessAuto = 1),0);
    IF (@titles IS NULL
      AND @inquiry IS NULL
      AND @platesticker IS NULL
      AND @parkingels IS NULL
      AND @parkingcard IS NULL
      AND @countrytaxes IS NULL
      AND @citysticker IS NULL)
    BEGIN
      SELECT
        NULL;
    END;
    ELSE
    BEGIN
      SELECT
        (ISNULL(@titles, 0) + ISNULL(@inquiry, 0) + ISNULL(@platesticker, 0) + ISNULL(@parkingels, 0) + ISNULL(@parkingcard, 0) + ISNULL(@countrytaxes, 0) + ISNULL(@citysticker, 0)) AS Fee;
    END;
  END;
  ELSE
  IF (@ProviderTypeCode = 'C09')
  BEGIN

    -- TRP
    --                 DECLARE @trp DECIMAL(18, 2);
    --                 SET @trp =
    --                 (
    --TrpFee = Trp cost
    --Fee1 = Fee service
    SELECT
      ISNULL(SUM(USD + ISNULL(Fee1, 0) + ISNULL(LaminationFee, 0) - ISNULL(TrpFee, 0)), 0) AS Fee
     ,COUNT(*) AS TotalTransactions
    FROM TRP
    WHERE AgencyId = @AgencyId
    AND CAST(DATEPART(MONTH, CreatedOn) AS INT) = @Month
    AND CAST(DATEPART(YEAR, CreatedOn) AS INT) = @Year
  --                 );
  --                 SELECT @trp;
  END;
  ELSE
  IF (@ProviderTypeCode = 'C24')
  BEGIN
    -- TICKETS

DECLARE @CommissionPaymentId INT;
DECLARE @ExisteComisionPagada BIT;

SELECT TOP 1
    @CommissionPaymentId = pcp.ProviderCommissionPaymentId
FROM ProviderCommissionPayments pcp
WHERE pcp.Month = @Month
  AND pcp.Year = @Year
  AND pcp.AgencyId = @AgencyId
  AND pcp.ProviderId = @ProviderId;

-- Asignar la bandera según si encontró id
SET @ExisteComisionPagada = CASE WHEN @CommissionPaymentId IS NOT NULL THEN 1 ELSE 0 END;


    SELECT
      ISNULL(dbo.fn_GetCommissionTickets(@AgencyId, @Month, @Year,@ExisteComisionPagada,@CommissionPaymentId),0) AS Fee,
      ISNULL(dbo.fn_GetCommissionTicketsMOAchFee(@AgencyId, @Month, @Year,@ExisteComisionPagada,@CommissionPaymentId),0) AS MOAchFee;
  END;
  ELSE
  IF (@ProviderTypeCode = 'C25')
  BEGIN

    -- CARD PAYMENT COMMISSION
    DECLARE @cardCommission DECIMAL(18, 2);
    --SET @cardCommission =
    --(
    SELECT
      ISNULL(SUM(FeeService), 0) Fee
     ,SUM(Transactions) TotalTransactions
    FROM dbo.[FN_GetComissionsCardPaymentsNew](NULL, NULL, @Month, @Year, @AgencyId, 1)
  --);
  --SELECT @cardCommission;
  END;
END;
--SELECT *
--FROM providers;
GO