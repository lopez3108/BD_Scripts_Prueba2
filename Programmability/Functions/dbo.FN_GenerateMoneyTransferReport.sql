SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:09-11-2023
--CAMBIOS EN 5430 

--LASTUPDATEDBY: ROMARIO
--LASTUPDATEDON:24-01-2024
--CAMBIOS EN 5550

--LASTUPDATEDBY: JT
--LASTUPDATEDON:8-02-2024
--Error que no estaba mostrando los cash payments cuando eran del mismo valor, mismo día, misma agencia

--LASTUPDATEDBY: JT
--LASTUPDATEDON:15-02-2024
--Error que no estaba mostrando los cash adjustments cuando eran del mismo valor, mismo día, misma agencia

--LASTUPDATEDBY: sergio
--LASTUPDATEDON:18-04-2024
--cambio de nombre de CLOSING FOREX DAILY a CLOSING DAILY FOREX
-- 2024-03-07 5652: Forex operation added to report

-- =============================================
-- Author:      JF
-- Create date: 20/07/2024 9:08 p. m.
-- Database:    copiaDevtest
-- Description: task 5905 Comisión pagada en 0.00 debe reflejarse en el reporte
-- =============================================

CREATE     FUNCTION [dbo].[FN_GenerateMoneyTransferReport] (@AgencyId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL,
@Date DATETIME,
@ProviderId INT)


RETURNS @result TABLE (

  [Index] INT
 ,[Type] VARCHAR(50)
 ,CreationDate DATETIME
 ,[Description] VARCHAR(500)
 ,Transactions INT
 ,Usd DECIMAL(18, 2)
 ,Balance DECIMAL(18, 2)

)
AS
BEGIN

  --ESTADO DELETE
  DECLARE @PaymentOthersStatusId INT;
  SET @PaymentOthersStatusId = (SELECT TOP 1
      pos.PaymentOtherStatusId
    FROM PaymentOthersStatus pos
    WHERE pos.Code = 'C03')

  -- Daily Money transfers

  INSERT INTO @result
    SELECT
      2
     ,t.Type
     ,t.CreationDate
     ,t.Description
     ,SUM(t.Transactions) Transactions
     ,CASE
        WHEN (SUM(t.Usd)) < 0 THEN (SUM(t.Usd) * -1)
        ELSE (SUM(t.Usd))
      END AS Usd
     ,CASE
        WHEN SUM(t.Usd) > 0 THEN 0 - (SUM(t.Usd))
        ELSE 0 + (SUM(t.Usd) * -1)
      END
    FROM (SELECT
        'CLOSING DAILY' AS Type
       ,CAST(dbo.Daily.CreationDate AS DATE) AS CreationDate
       ,'CLOSING DAILY M.T' AS Description
       ,SUM(ISNULL(dbo.MoneyTransfers.Transactions, 0)) Transactions
       ,SUM(ISNULL(dbo.MoneyTransfers.Usd, 0)) AS Usd
      FROM dbo.Daily
      INNER JOIN dbo.Cashiers
        ON dbo.Cashiers.CashierId = dbo.Daily.CashierId
      INNER JOIN dbo.MoneyTransfers
        ON dbo.Daily.AgencyId = dbo.MoneyTransfers.AgencyId
        AND CAST(dbo.MoneyTransfers.CreationDate AS DATE) = CAST(Daily.CreationDate AS DATE)
        AND dbo.Cashiers.UserId = dbo.MoneyTransfers.CreatedBy
        AND dbo.MoneyTransfers.TotalTransactions > 0
        AND dbo.MoneyTransfers.Transactions > 0
      INNER JOIN dbo.Providers
        ON dbo.MoneyTransfers.ProviderId = dbo.Providers.ProviderId
      --AND dbo.Providers.MoneyOrderService = 1
      WHERE dbo.Daily.AgencyId = @AgencyId
      --AND (dbo.MoneyTransfers.TotalTransactions <= 0 OR dbo.MoneyTransfers.TotalTransactions IS NULL )
      AND CAST(dbo.Daily.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
      AND CAST(dbo.Daily.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
      AND dbo.MoneyTransfers.ProviderId = @ProviderId
      GROUP BY CAST(dbo.Daily.CreationDate AS DATE)) t
    GROUP BY t.CreationDate
            ,t.Type
            ,t.Description;

  -- Daily MONEY ORDERS
  INSERT INTO @result
    SELECT
      3
     ,t.Type
     ,t.CreationDate
     ,t.Description
     ,SUM(t.Transactions) Transactions
     ,ABS(SUM(t.Usd)) AS Usd
     ,0 - ABS(SUM(t.Usd))
    FROM (SELECT
        'CLOSING DAILY' AS Type
       ,CAST(dbo.Daily.CreationDate AS DATE) AS CreationDate
       ,'CLOSING DAILY M.O' AS Description
       ,SUM(ISNULL(dbo.MoneyTransfers.TransactionsNumberMoneyOrders, 0)) Transactions
       ,SUM((ISNULL(dbo.MoneyTransfers.UsdMoneyOrders, 0)) - (ISNULL(dbo.MoneyTransfers.MoneyOrderFee, 0)) * (ISNULL(dbo.MoneyTransfers.TransactionsNumberMoneyOrders, 0))) AS Usd
      FROM dbo.Daily
      INNER JOIN dbo.Cashiers
        ON dbo.Cashiers.CashierId = dbo.Daily.CashierId
      INNER JOIN dbo.MoneyTransfers
        ON MoneyTransfers.TransactionsNumberMoneyOrders > 0
        AND dbo.Daily.AgencyId = dbo.MoneyTransfers.AgencyId
        AND CAST(dbo.MoneyTransfers.CreationDate AS DATE) = CAST(Daily.CreationDate AS DATE)
        AND dbo.Cashiers.UserId = dbo.MoneyTransfers.CreatedBy
      INNER JOIN dbo.Providers
        ON dbo.MoneyTransfers.ProviderId = dbo.Providers.ProviderId
      --                                                     AND dbo.Providers.MoneyOrderService = 1 4600 se comento porque independientemente si el providers esta inactivo se debe de mostrar la operacion con este provider.
      WHERE dbo.Daily.AgencyId = @AgencyId
      AND CAST(dbo.Daily.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
      AND CAST(dbo.Daily.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
      AND dbo.MoneyTransfers.ProviderId = @ProviderId
      GROUP BY CAST(dbo.Daily.CreationDate AS DATE)) t
    GROUP BY t.CreationDate
            ,t.Type
            ,t.Description
            ,t.Transactions;

  -- Daily MONEY ORDERS COMMISSIONS
  INSERT INTO @result
    SELECT
      4
     ,t.Type
     ,t.CreationDate
     ,t.Description
     ,SUM(t.Transactions)
     ,ABS(SUM(t.Usd)) AS Usd
     ,0 - ABS(SUM(t.Usd))
    FROM (SELECT
        'CLOSING DAILY' AS Type
       ,CAST(dbo.Daily.CreationDate AS DATE) AS CreationDate
       ,'CLOSING DAILY M.O FEE' AS Description
       ,SUM(ISNULL(dbo.MoneyTransfers.TransactionsNumberMoneyOrders, 0)) Transactions
       ,SUM(ISNULL(dbo.MoneyTransfers.TransactionsNumberMoneyOrders, 0) * ISNULL(dbo.MoneyTransfers.ProviderMoneyCommission, 0)) AS Usd
      FROM dbo.Daily
      INNER JOIN dbo.Cashiers
        ON dbo.Cashiers.CashierId = dbo.Daily.CashierId
      INNER JOIN dbo.MoneyTransfers
        ON MoneyTransfers.TransactionsNumberMoneyOrders > 0
        AND dbo.Daily.AgencyId = dbo.MoneyTransfers.AgencyId
        AND CAST(dbo.MoneyTransfers.CreationDate AS DATE) = CAST(Daily.CreationDate AS DATE)
        AND dbo.Cashiers.UserId = dbo.MoneyTransfers.CreatedBy
      INNER JOIN dbo.Providers
        ON dbo.MoneyTransfers.ProviderId = dbo.Providers.ProviderId
      --                                                     AND dbo.Providers.MoneyOrderService = 1
      WHERE dbo.Daily.AgencyId = @AgencyId
      --AND Usd > 0
      AND CAST(dbo.Daily.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
      AND CAST(dbo.Daily.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
      AND dbo.MoneyTransfers.ProviderId = @ProviderId
      GROUP BY CAST(dbo.Daily.CreationDate AS DATE)) t
    WHERE t.Usd > 0
    GROUP BY t.CreationDate
            ,t.Type
            ,t.Description
            ,t.Transactions;

  -- Payment cash

  INSERT INTO @result
    SELECT
      5
     ,'CASH PAYMENT' AS Type
     ,dbo.PaymentCash.Date AS CreationDate
     ,dbo.Providers.Name + ' - ' + ISNULL((SELECT TOP 1
          mt.Number
        FROM MoneyTransferxAgencyNumbers mt
        WHERE mt.AgencyId = dbo.PaymentCash.AgencyId
        AND mt.ProviderId = dbo.PaymentCash.ProviderId)
      , 'Number not registered') AS Description
     ,COUNT(*) Transactions
     ,dbo.PaymentCash.Usd AS Usd
     ,0 + dbo.PaymentCash.Usd
    FROM dbo.PaymentCash
    INNER JOIN dbo.Providers
      ON dbo.PaymentCash.ProviderId = dbo.Providers.ProviderId
    WHERE (DeletedOn IS NULL
    AND DeletedBy IS NULL
    AND Status != @PaymentOthersStatusId)
    AND CAST(dbo.PaymentCash.Date AS DATE) >= CAST(@FromDate AS DATE)
    AND CAST(dbo.PaymentCash.Date AS DATE) <= CAST(@ToDate AS DATE)
    AND dbo.PaymentCash.AgencyId = @AgencyId
    AND dbo.PaymentCash.ProviderId = @ProviderId
    GROUP BY dbo.PaymentCash.Date
            ,dbo.PaymentCash.Usd
            ,dbo.PaymentCash.PaymentCashId
            ,dbo.Providers.Name
            ,dbo.PaymentCash.AgencyId
            ,dbo.PaymentCash.ProviderId



  -- Adjustment to

  INSERT INTO @result
    SELECT
      6
     ,'ADJUSTMENT TO' AS Type
     ,dbo.PaymentAdjustment.Date AS CreationDate
     ,'FROM ' + ISNULL((SELECT TOP 1
          mt.Number
        FROM MoneyTransferxAgencyNumbers mt
        WHERE mt.AgencyId = dbo.PaymentAdjustment.AgencyFromId
        AND mt.ProviderId = dbo.PaymentAdjustment.ProviderId)
      , '')
      + ' TO ' + ISNULL((SELECT TOP 1
          mt.Number
        FROM MoneyTransferxAgencyNumbers mt
        WHERE mt.AgencyId = dbo.PaymentAdjustment.AgencyToId
        AND mt.ProviderId = dbo.PaymentAdjustment.ProviderId)
      , '')
      --     ,'FROM ' + (SELECT TOP 1
      --          Code
      --        FROM dbo.Agencies
      --        WHERE dbo.Agencies.AgencyId = dbo.PaymentAdjustment.AgencyFromId)
      --      + ' TO ' + (SELECT TOP 1
      --          Code
      --        FROM dbo.Agencies
      --        WHERE dbo.Agencies.AgencyId = dbo.PaymentAdjustment.AgencyToId)
      AS Description
     ,COUNT(*) Transactions
     ,Usd AS Usd
     ,0 + Usd
    FROM dbo.PaymentAdjustment
    LEFT JOIN dbo.Providers p
      ON PaymentAdjustment.ProviderId = p.ProviderId
    INNER JOIN MoneyTransferxAgencyNumbers
      ON MoneyTransferxAgencyNumbers.AgencyId = dbo.PaymentAdjustment.AgencyToId
        AND MoneyTransferxAgencyNumbers.ProviderId = dbo.PaymentAdjustment.ProviderId
        AND AgencyToId = @AgencyId
        AND MoneyTransferxAgencyNumbers.ProviderId = @ProviderId
    WHERE AgencyToId = @AgencyId
    AND CAST(dbo.PaymentAdjustment.Date AS DATE) >= CAST(@FromDate AS DATE)
    AND CAST(dbo.PaymentAdjustment.Date AS DATE) <= CAST(@ToDate AS DATE)
    AND PaymentAdjustment.DeletedBy IS NULL
    AND PaymentAdjustment.DeletedOn IS NULL
    GROUP BY dbo.PaymentAdjustment.Date
            ,dbo.PaymentAdjustment.AgencyToId
            ,dbo.PaymentAdjustment.AgencyFromId
            ,dbo.PaymentAdjustment.ProviderId
            ,p.Name
            ,Usd
            ,dbo.PaymentAdjustment.PaymentAdjustmentId



  -- Adjustment from

  INSERT INTO @result
    SELECT
      7
     ,'ADJUSTMENT FROM' AS Type
     ,dbo.PaymentAdjustment.Date AS CreationDate
     ,'FROM ' + ISNULL((SELECT TOP 1
          mt.Number
        FROM MoneyTransferxAgencyNumbers mt
        WHERE mt.AgencyId = dbo.PaymentAdjustment.AgencyFromId
        AND mt.ProviderId = dbo.PaymentAdjustment.ProviderId)
      , '')
      + ' TO ' + ISNULL((SELECT TOP 1
          mt.Number
        FROM MoneyTransferxAgencyNumbers mt
        WHERE mt.AgencyId = dbo.PaymentAdjustment.AgencyToId
        AND mt.ProviderId = dbo.PaymentAdjustment.ProviderId)
      , '')
      AS Description
     ,COUNT(*) Transactions
     ,Usd AS Usd
     ,0 - Usd
    FROM dbo.PaymentAdjustment
    LEFT JOIN dbo.Providers p
      ON PaymentAdjustment.ProviderId = p.ProviderId
    WHERE AgencyFromId = @AgencyId
    AND dbo.PaymentAdjustment.ProviderId = @ProviderId
    AND CAST(dbo.PaymentAdjustment.Date AS DATE) >= CAST(@FromDate AS DATE)
    AND CAST(dbo.PaymentAdjustment.Date AS DATE) <= CAST(@ToDate AS DATE)
    AND dbo.PaymentAdjustment.DeletedBy IS NULL
    AND dbo.PaymentAdjustment.DeletedOn IS NULL
    GROUP BY dbo.PaymentAdjustment.Date
            ,dbo.PaymentAdjustment.AgencyToId
            ,dbo.PaymentAdjustment.ProviderId
            ,dbo.PaymentAdjustment.AgencyFromId
            ,p.Name
            ,Usd
            ,dbo.PaymentAdjustment.PaymentAdjustmentId


  -- Checks

  INSERT INTO @result
    SELECT
      8
     ,'PROCESSED CHECKS' AS Type
     ,dbo.PaymentChecksAgentToAgent.Date AS CreationDate
     ,'FROM ' + (SELECT TOP 1
          Code
        FROM dbo.Agencies
        WHERE dbo.Agencies.AgencyId = dbo.PaymentChecksAgentToAgent.FromAgency)
      + ' TO ' + (SELECT TOP 1
          Code
        FROM dbo.Agencies
        WHERE dbo.Agencies.AgencyId = dbo.PaymentChecksAgentToAgent.ToAgency)
      + ' BATCH #: ' + dbo.PaymentChecksAgentToAgent.providerBatch
      AS Description
     ,dbo.PaymentChecksAgentToAgent.NumberChecks Transactions
     ,Usd
     ,0 + Usd
    FROM dbo.PaymentChecksAgentToAgent
    WHERE ToAgency = @AgencyId
    AND ProviderId = @ProviderId
    AND CAST(dbo.PaymentChecksAgentToAgent.Date AS DATE) >= CAST(@FromDate AS DATE)
    AND CAST(dbo.PaymentChecksAgentToAgent.Date AS DATE) <= CAST(@ToDate AS DATE)
    GROUP BY dbo.PaymentChecksAgentToAgent.Date
            ,dbo.PaymentChecksAgentToAgent.FromAgency
            ,dbo.PaymentChecksAgentToAgent.ToAgency
            ,Usd
            ,dbo.PaymentChecksAgentToAgent.NumberChecks
            ,dbo.PaymentChecksAgentToAgent.providerBatch



  -- Checks fee

  INSERT INTO @result
    SELECT
      9
     ,'PROCESSED CHECKS FEE' AS Type
     ,dbo.PaymentChecksAgentToAgent.Date AS CreationDate
     ,'FROM ' + (SELECT TOP 1
          Code
        FROM dbo.Agencies
        WHERE dbo.Agencies.AgencyId = dbo.PaymentChecksAgentToAgent.FromAgency)
      + ' TO ' + (SELECT TOP 1
          Code
        FROM dbo.Agencies
        WHERE dbo.Agencies.AgencyId = dbo.PaymentChecksAgentToAgent.ToAgency)
      + ' BATCH: #' + dbo.PaymentChecksAgentToAgent.providerBatch
      AS Description
     ,(SELECT
          COUNT(ce.CheckElsId)
        FROM dbo.ChecksEls ce
        WHERE ce.PaymentChecksAgentToAgentId = dbo.PaymentChecksAgentToAgent.PaymentChecksAgentToAgentId
        AND Fee > 0)
      Transactions
     ,
      --Total transaciones con Fee 0 no se deben de mostrar en reportes de money transfer 
      ABS(ISNULL(ProviderCheckfee * dbo.PaymentChecksAgentToAgent.NumberChecks, 0)) AS Usd
     ,0 - ABS(ISNULL(ProviderCheckfee * dbo.PaymentChecksAgentToAgent.NumberChecks, 0))
    FROM dbo.PaymentChecksAgentToAgent
    WHERE ToAgency = @AgencyId
    AND ProviderId = @ProviderId
    AND CAST(dbo.PaymentChecksAgentToAgent.Date AS DATE) >= CAST(@FromDate AS DATE)
    AND CAST(dbo.PaymentChecksAgentToAgent.Date AS DATE) <= CAST(@ToDate AS DATE)
    AND ProviderCheckfee > 0;

  -- Payment checks

  INSERT INTO @result
    SELECT
      10
     ,t.Type
     ,t.CreationDate
     ,t.Description
     ,COUNT(*) Transactions
     ,ABS(SUM(t.Usd)) AS Usd
     ,0 + ABS(SUM(t.Usd))
    FROM (SELECT
        'PAYMENT CHECKS' AS Type
       ,CAST(pc.Date AS DATE) AS CreationDate
       ,dbo.Agencies.Code + ' ' +
        CASE
          WHEN dbo.ProviderTypes.Code = 'C02' THEN ISNULL((SELECT TOP 1
                mt.Number
              FROM MoneyTransferxAgencyNumbers mt
              WHERE mt.AgencyId = pc.AgencyId
              AND mt.ProviderId = pc.ProviderId)
            , 'Not registered')
          ELSE dbo.Providers.Name
        END + ' ' + CAST(CONVERT(VARCHAR, pc.FromDate, 110) AS VARCHAR(10)) + ' TO ' + CAST(CONVERT(VARCHAR, pc.ToDate, 110) AS VARCHAR(10)) AS Description
       ,Usd AS Usd
      FROM dbo.PaymentChecks pc
      INNER JOIN dbo.Agencies
        ON pc.AgencyId = dbo.Agencies.AgencyId
      INNER JOIN dbo.Providers
        ON pc.ProviderId = dbo.Providers.ProviderId
      INNER JOIN dbo.ProviderTypes
        ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
      WHERE ((@FromDate IS NULL)
      OR (CAST([Date] AS DATE) >= CAST(@FromDate AS DATE)))
      AND ((@ToDate IS NULL)
      OR (CAST([Date] AS DATE) <= CAST(@ToDate AS DATE)))
      AND pc.AgencyId = @AgencyId
      AND pc.ProviderId = @ProviderId) t
    GROUP BY t.CreationDate
            ,t.Type
            ,t.Description;


  -- Payment checks fee

  INSERT INTO @result
    SELECT
      11
     ,t.Type
     ,t.CreationDate
     ,t.Description
     ,COUNT(*) Transactions
     ,ABS(SUM(t.Usd)) AS Usd
     ,0 - ABS(SUM(t.Usd))
    FROM (SELECT
        'PAYMENT CHECKS FEE' AS Type
       ,CAST(pc.Date AS DATE) AS CreationDate
       ,dbo.Agencies.Code + ' - ' + dbo.Agencies.Name + ' (' +
        CASE
          WHEN dbo.ProviderTypes.Code = 'C02' THEN ISNULL((SELECT TOP 1
                mt.Number
              FROM MoneyTransferxAgencyNumbers mt
              WHERE mt.AgencyId = pc.AgencyId
              AND mt.ProviderId = pc.ProviderId)
            , 'Number not registered')
          ELSE dbo.Providers.Name
        END + ') ' + CAST(CONVERT(VARCHAR, pc.FromDate, 110) AS VARCHAR(10)) + ' TO ' + CAST(CONVERT(VARCHAR, pc.ToDate, 110) AS VARCHAR(10)) AS Description
       ,Fee AS Usd
      FROM dbo.PaymentChecks pc
      INNER JOIN dbo.Agencies
        ON pc.AgencyId = dbo.Agencies.AgencyId
      INNER JOIN dbo.Providers
        ON pc.ProviderId = dbo.Providers.ProviderId
      INNER JOIN dbo.ProviderTypes
        ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
      WHERE ((@FromDate IS NULL)
      OR (CAST([Date] AS DATE) >= CAST(@FromDate AS DATE)))
      AND ((@ToDate IS NULL)
      OR (CAST([Date] AS DATE) <= CAST(@ToDate AS DATE)))
      AND pc.AgencyId = @AgencyId
      AND Fee > 0
      AND pc.ProviderId = @ProviderId) t
    GROUP BY t.CreationDate
            ,t.Type
            ,t.Description;

  -- Payment other (credit) (4980) DE CREDIT A DEBIT Y VICEVERSA
  INSERT INTO @result
    SELECT
      12
     ,'PAYMENT OTHER DEBIT' AS Type
     ,dbo.PaymentOthers.Date AS CreationDate
     ,
      --     (SELECT TOP 1
      --          NP.Note
      --        FROM NotesXPaymentOthers NP
      --        WHERE NP.PaymentOthersId = dbo.PaymentOthers.PaymentOthersId
      --        ORDER BY CreationDate ASC)
      'PAYMENT OTHER DEBIT' AS Description
     ,COUNT(*) Transactions
     ,SUM(Usd) AS Usd
     ,0 + SUM(Usd)
    FROM dbo.PaymentOthers
    WHERE (DeletedOn IS NULL
    AND DeletedBy IS NULL
    AND PaymentOtherStatusId != @PaymentOthersStatusId)
    AND AgencyId = @AgencyId
    AND ProviderId = @ProviderId
    AND IsDebit = 0
    AND CAST(dbo.PaymentOthers.Date AS DATE) >= CAST(@FromDate AS DATE)
    AND CAST(dbo.PaymentOthers.Date AS DATE) <= CAST(@ToDate AS DATE)
    GROUP BY dbo.PaymentOthers.Date
  --            ,dbo.PaymentOthers.PaymentOthersId




  -- Payment other (debit)

  INSERT INTO @result
    SELECT
      13
     ,'PAYMENT OTHER CREDIT' AS Type
     ,dbo.PaymentOthers.Date AS CreationDate
     ,
      --     (SELECT TOP 1
      --          ISNULL(NP.Note, '-')
      --        FROM NotesXPaymentOthers NP
      --        WHERE NP.PaymentOthersId = dbo.PaymentOthers.PaymentOthersId
      --        ORDER BY CreationDate ASC)
      'PAYMENT OTHER CREDIT' AS Description
     ,COUNT(*) Transactions
     ,SUM(Usd) AS Usd
     ,0 - SUM(Usd)
    FROM dbo.PaymentOthers
    WHERE (DeletedOn IS NULL
    AND DeletedBy IS NULL
    AND PaymentOtherStatusId != @PaymentOthersStatusId)
    AND AgencyId = @AgencyId
    AND ProviderId = @ProviderId
    AND IsDebit = 1
    AND CAST(dbo.PaymentOthers.Date AS DATE) >= CAST(@FromDate AS DATE)
    AND CAST(dbo.PaymentOthers.Date AS DATE) <= CAST(@ToDate AS DATE)
    GROUP BY dbo.PaymentOthers.Date
  --            ,dbo.PaymentOthers.PaymentOthersId




  -- Returned checks

  INSERT INTO @result
    SELECT
      14
     ,'RETURNED CHECK' AS Type
     ,dbo.ReturnedCheck.ReturnDate AS CreationDate
     ,'RETURNED CHECK - CHECK NUMBER:' + dbo.ReturnedCheck.CheckNumber AS Description
     ,COUNT(*) Transactions
     ,Usd AS Usd
     ,0 - Usd
    FROM dbo.ReturnedCheck
    WHERE ReturnedAgencyId = @AgencyId
    AND ProviderId = @ProviderId
    AND CAST(dbo.ReturnedCheck.ReturnDate AS DATE) >= CAST(@FromDate AS DATE)
    AND CAST(dbo.ReturnedCheck.ReturnDate AS DATE) <= CAST(@ToDate AS DATE)
    GROUP BY dbo.ReturnedCheck.ReturnDate
            ,dbo.ReturnedCheck.CheckNumber
            ,Usd

  -- Returned checks fee

  INSERT INTO @result
    SELECT
      15
     ,'RETURNED CHECK FEE' AS Type
     ,dbo.ReturnedCheck.ReturnDate AS CreationDate
     ,'RETURNED CHECK FEE - CHECK NUMBER:' + dbo.ReturnedCheck.CheckNumber AS Description
     ,COUNT(*) Transactions
     ,ProviderFee AS Usd
     ,0 - ProviderFee
    FROM dbo.ReturnedCheck
    WHERE ProviderFee > 0
    AND ReturnedAgencyId = @AgencyId
    AND ProviderId = @ProviderId
    AND CAST(dbo.ReturnedCheck.ReturnDate AS DATE) >= CAST(@FromDate AS DATE)
    AND CAST(dbo.ReturnedCheck.ReturnDate AS DATE) <= CAST(@ToDate AS DATE)
    GROUP BY dbo.ReturnedCheck.ReturnDate
            ,dbo.ReturnedCheck.CheckNumber
            ,ProviderFee

  -- Cancellation

  INSERT INTO @result
    SELECT
      16
     ,'CANCELLATION' AS Type
     ,dbo.Cancellations.CancellationDate AS CreationDate
     ,CASE
        WHEN dbo.CancellationTypes.Code = 'C01' THEN 'CANCELLATION - ' + dbo.Cancellations.ReceiptCancelledNumber + ' (M.T)'
        WHEN dbo.CancellationTypes.Code = 'C02' THEN 'CANCELLATION - ' + dbo.Cancellations.ReceiptCancelledNumber + ' (M.O)'
        ELSE 'CANCELLATION - ' + dbo.Cancellations.ReceiptCancelledNumber
      END AS Description
     ,1 Transactions
     ,(TotalTransaction + Fee) * -1 AS Usd
     ,0 + ((TotalTransaction + Fee) * -1)
    FROM dbo.Cancellations
    INNER JOIN dbo.Providers
      ON dbo.Cancellations.ProviderCancelledId = dbo.Providers.ProviderId
    INNER JOIN dbo.ProviderTypes
      ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
    LEFT JOIN dbo.CancellationTypes
      ON dbo.CancellationTypes.CancellationTypeId = dbo.Cancellations.CancellationTypeId
    WHERE AgencyId = @AgencyId
    AND ProviderCancelledId = @ProviderId
    AND CAST(dbo.Cancellations.CancellationDate AS DATE) >= CAST(@FromDate AS DATE)
    AND CAST(dbo.Cancellations.CancellationDate AS DATE) <= CAST(@ToDate AS DATE);

  -- Money distribution

  INSERT INTO @result
    SELECT
      17
     ,'MONEY DISTRIBUTION' AS Type
     ,dbo.Daily.CreationDate AS CreationDate
     ,'FROM ' + dbo.Agencies.Code + ' BAG# ' + DailyDistribution.PackageNumber + ' TO ' + Agencies_1.Code AS Description
     ,
      --'CASHIER: '+dbo.Users.Name+' AGENCY '+dbo.Agencies.Code+' - '+dbo.Agencies.Name+' TO AGENCY '+Agencies_1.Code+' - '+Agencies_1.Name+' '+dbo.Providers.Name+' ('+dbo.DailyDistribution.Code+')' AS Description,
      1 Transactions
     ,dbo.DailyDistribution.Usd
     ,0 + dbo.DailyDistribution.Usd
    FROM dbo.DailyDistribution
    INNER JOIN dbo.Daily
      ON dbo.DailyDistribution.DailyId = dbo.Daily.DailyId
    INNER JOIN dbo.Agencies
      ON dbo.Daily.AgencyId = dbo.Agencies.AgencyId
    INNER JOIN dbo.Agencies AS Agencies_1
      ON dbo.DailyDistribution.AgencyId = Agencies_1.AgencyId
    INNER JOIN dbo.Providers
      ON dbo.DailyDistribution.ProviderId = dbo.Providers.ProviderId
    INNER JOIN dbo.Cashiers
      ON dbo.Daily.CashierId = dbo.Cashiers.CashierId
    INNER JOIN dbo.Users
      ON dbo.Cashiers.UserId = dbo.Users.UserId
    WHERE dbo.DailyDistribution.Usd > 0  AND dbo.DailyDistribution.AgencyId = @AgencyId
    AND dbo.DailyDistribution.ProviderId = @ProviderId
    AND CAST(dbo.Daily.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
    AND CAST(dbo.Daily.CreationDate AS DATE) <= CAST(@ToDate AS DATE);


  -- Cash agent to agent

  INSERT INTO @result
    SELECT
      18
     ,'CASH (AGENCY TO AGENCY) PROVIDER' AS Type
     ,dbo.PaymentCashAgentToAgent.Date AS CreationDate
     ,'FROM AGENCY ' + (SELECT TOP 1
          Code
        FROM Agencies
        WHERE AgencyId = dbo.PaymentCashAgentToAgent.FromAgencyId)
      + ' TO AGENCY ' + (SELECT TOP 1
          Code
        FROM Agencies
        WHERE AgencyId = dbo.PaymentCashAgentToAgent.AgencyId)
      AS Description
     ,COUNT(*) Transactions
     ,Usd AS Usd
     ,0 + Usd
    FROM dbo.PaymentCashAgentToAgent
    WHERE dbo.PaymentCashAgentToAgent.AgencyId = @AgencyId
    AND dbo.PaymentCashAgentToAgent.ProviderId = @ProviderId
    AND CAST(dbo.PaymentCashAgentToAgent.Date AS DATE) >= CAST(@FromDate AS DATE)
    AND CAST(dbo.PaymentCashAgentToAgent.Date AS DATE) <= CAST(@ToDate AS DATE)
    AND dbo.PaymentCashAgentToAgent.DeletedOn IS NULL
    GROUP BY dbo.PaymentCashAgentToAgent.Date
            ,dbo.PaymentCashAgentToAgent.FromAgencyId
            ,dbo.PaymentCashAgentToAgent.AgencyId
            ,Usd


  -- Commission payment - Adjustment
  INSERT INTO @result
    SELECT
      19
     ,'ADJUSTMENT' AS Type
     ,CAST(dbo.ProviderCommissionPayments.AdjustmentDate AS DATE) AS CreationDate
     ,'COMMISSIONS ' + UPPER(DATENAME(MONTH, DATEADD(MONTH, dbo.ProviderCommissionPayments.Month, 0) - 1)) + ' ' + CAST(dbo.ProviderCommissionPayments.Year AS VARCHAR(4)) AS Description
     ,COUNT(*) Transactions
     ,Usd
     ,0 + Usd
    FROM dbo.ProviderCommissionPayments
    INNER JOIN ProviderCommissionPaymentTypes pt
      ON pt.ProviderCommissionPaymentTypeId = dbo.ProviderCommissionPayments.ProviderCommissionPaymentTypeId
    WHERE dbo.ProviderCommissionPayments.AgencyId = @AgencyId
    AND dbo.ProviderCommissionPayments.ProviderId = @ProviderId
    AND CAST(dbo.ProviderCommissionPayments.AdjustmentDate AS DATE) >= CAST(@FromDate AS DATE)
    AND CAST(dbo.ProviderCommissionPayments.AdjustmentDate AS DATE) <= CAST(@ToDate AS DATE)
    AND pt.Code = 'CODE04'
    AND ProviderCommissionPayments.IsForex = CAST(0 AS BIT)
    GROUP BY CAST(dbo.ProviderCommissionPayments.AdjustmentDate AS DATE)
            ,dbo.ProviderCommissionPayments.MONTH
            ,dbo.ProviderCommissionPayments.Year
            ,Usd

  -- Concilliation money transfer

  INSERT INTO @result --MT Credit 
    SELECT
      20
     ,'BANK PAYMENT CREDIT' AS Type
     ,CAST([Date] AS DATE) CreationDate
     ,'*** ' + dbo.BankAccounts.AccountNumber + ' (' + dbo.Bank.Name + ')' Description
     ,COUNT(*) Transactions
     ,SUM(Usd) Usd
     ,0 - SUM(Usd) Balance
    FROM dbo.ConciliationMoneyTransfers
    INNER JOIN dbo.BankAccounts
      ON dbo.BankAccounts.BankAccountId = dbo.ConciliationMoneyTransfers.BankAccountId
    INNER JOIN dbo.Bank
      ON dbo.Bank.BankId = dbo.BankAccounts.BankId
    WHERE IsCredit = 1
    AND AgencyId = @AgencyId
    AND ProviderId = @ProviderId
    AND CAST(dbo.ConciliationMoneyTransfers.Date AS DATE) >= CAST(@FromDate AS DATE)
    AND CAST(dbo.ConciliationMoneyTransfers.Date AS DATE) <= CAST(@ToDate AS DATE)
    GROUP BY CAST(dbo.ConciliationMoneyTransfers.Date AS DATE)
            ,dbo.BankAccounts.AccountNumber
            ,dbo.Bank.Name





  INSERT INTO @result --MT Debit 
    SELECT
      21
     ,'BANK PAYMENT DEBIT' AS Type
     ,CAST([Date] AS DATE) CreationDate
     ,'*** ' + dbo.BankAccounts.AccountNumber + ' (' + dbo.Bank.Name + ')' Description
     ,COUNT(*) Transactions
     ,SUM(Usd) usd
     ,0 + SUM(Usd) Balance
    FROM dbo.ConciliationMoneyTransfers
    INNER JOIN dbo.BankAccounts
      ON dbo.BankAccounts.BankAccountId = dbo.ConciliationMoneyTransfers.BankAccountId
    INNER JOIN dbo.Bank
      ON dbo.Bank.BankId = dbo.BankAccounts.BankId
    WHERE IsCredit = 0
    AND AgencyId = @AgencyId
    AND ProviderId = @ProviderId
    AND CAST(dbo.ConciliationMoneyTransfers.Date AS DATE) >= CAST(@FromDate AS DATE)
    AND CAST(dbo.ConciliationMoneyTransfers.Date AS DATE) <= CAST(@ToDate AS DATE)
    GROUP BY CAST([Date] AS DATE)
            ,dbo.BankAccounts.AccountNumber
            ,dbo.Bank.Name





  INSERT INTO @result --Smart safe deposit Debit 
    SELECT
      22
     ,'SMART SAFE DEPOSIT' AS Type
     ,CAST(s.CreationDate AS DATE) CreationDate
     ,'CLOSING DAILY SMART SAFE DEPOSIT' Description
     ,COUNT(*) Transactions
     ,ABS(SUM(ABS(Usd))) AS Usd
     ,0 + ABS(SUM(ABS(Usd)))
    FROM SmartSafeDeposit s
    WHERE s.AgencyId = @AgencyId
    AND ProviderId = @ProviderId
    AND CAST(s.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
    AND CAST(s.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
    GROUP BY CAST(s.CreationDate AS DATE)


  INSERT INTO @result --cash advance or back task:5550
    SELECT
      23
     ,'CASH ADVANCE OR BACK' AS Type
     ,CAST(caob.CreationDate AS DATE) CreationDate
     ,'CLOSING DAILY CASH ADVANCE OR BACK' AS Description
     ,COUNT(*) Transactions
     ,SUM(caob.Usd) AS Usd
     ,-SUM(caob.Usd)
    FROM dbo.CashAdvanceOrBack caob
    INNER JOIN dbo.Users u
      ON u.UserId = caob.CreatedBy
    WHERE caob.AgencyId = @AgencyId
    AND ProviderId = @ProviderId
    AND CAST(caob.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
    AND CAST(caob.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
    GROUP BY CAST(caob.CreationDate AS DATE)
--            ,caob.TransactionId


  -- Daily MONEY ORDERS COMMISSIONS
  INSERT INTO @result
    SELECT
      24
     ,'ADJUSTMENT' AS Type
     ,CAST(dbo.ProviderCommissionPayments.AdjustmentDate AS DATE) AS CreationDate
     ,'COMMISSIONS ' + UPPER(DATENAME(MONTH, DATEADD(MONTH, dbo.ProviderCommissionPayments.Month, 0) - 1)) + ' ' +
      CAST(dbo.ProviderCommissionPayments.Year AS VARCHAR(4)) + ' ' + 'FOREX' AS Description
     ,COUNT(*) Transactions
     ,Usd
     ,0 + Usd
    FROM dbo.ProviderCommissionPayments
    INNER JOIN ProviderCommissionPaymentTypes pt
      ON pt.ProviderCommissionPaymentTypeId = dbo.ProviderCommissionPayments.ProviderCommissionPaymentTypeId
    WHERE dbo.ProviderCommissionPayments.AgencyId = @AgencyId
    AND dbo.ProviderCommissionPayments.ProviderId = @ProviderId
    AND CAST(dbo.ProviderCommissionPayments.AdjustmentDate AS DATE) >= CAST(@FromDate AS DATE)
    AND CAST(dbo.ProviderCommissionPayments.AdjustmentDate AS DATE) <= CAST(@ToDate AS DATE)
    AND pt.Code = 'CODE04'
    AND ProviderCommissionPayments.IsForex = CAST(1 AS BIT)
    GROUP BY CAST(dbo.ProviderCommissionPayments.AdjustmentDate AS DATE)
            ,dbo.ProviderCommissionPayments.MONTH
            ,dbo.ProviderCommissionPayments.Year
            ,Usd

			  INSERT INTO @result -- 5652: Forex Credit (Debit in report)
    SELECT
      25
     ,'CLOSING DAILY FOREX' AS Type
     ,CAST(f.ToDate AS DATE) CreationDate
     ,'FOREX (DAILY) FROM ' + FORMAT(f.FromDate, 'MM-dd-yyyy ') + ' TO ' + FORMAT(f.ToDate, 'MM-dd-yyyy ') Description
     ,'-'
     ,ABS(SUM(ABS(Usd))) AS Usd
     ,ABS(SUM(ABS(Usd)))
    FROM dbo.Forex f
    WHERE f.AgencyId = @AgencyId
    AND f.ProviderId = @ProviderId
	AND (CAST(f.FromDate AS DATE) >= CAST(@FromDate as DATE) and
    CAST(f.ToDate AS DATE) <= CAST(@ToDate AS DATE))
    GROUP BY CAST(f.CreationDate AS DATE), f.FromDate, f.ToDate

	DECLARE @forexExpenseType INT
		   SET @forexExpenseType = (SELECT TOP 1 e.ExpensesTypeId FROM dbo.ExpensesType e WHERE e.Code = 'C15')

	INSERT INTO @result -- 5652: Forex Debit (Credit in report)
    SELECT
      25
     ,'CLOSING FOREX EXPENSE' AS Type
     ,CAST(f.ToDate AS DATE) CreationDate
     ,'FOREX (EXPENSE) FROM ' + FORMAT(f.FromDate, 'MM-dd-yyyy ') + ' TO ' + FORMAT(f.ToDate, 'MM-dd-yyyy ') Description
     ,'-'
     ,ABS(SUM(ABS(Usd))) AS Usd
     ,SUM(ABS(Usd)) * -1
    FROM dbo.Expenses f
    WHERE f.AgencyId = @AgencyId
    AND f.ProviderId = @ProviderId
   AND (CAST(f.FromDate AS DATE) >= CAST(@FromDate as DATE) and
    CAST(f.ToDate AS DATE) <= CAST(@ToDate AS DATE))
	AND f.ExpenseTypeId = @forexExpenseType
    GROUP BY CAST(f.CreatedOn AS DATE), f.FromDate, f.ToDate




 INSERT INTO @result
    SELECT
      26
--     ,'COMMISSION' AS Type
     ,'COMMISSION' AS Type
     ,dbo.[fn_GetNextDayPeriod](Year, Month) AS CreationDate
     ,'CLOSING COMISSION ' + dbo.[fn_GetMonthByNum](Month) + '-' + CAST(Year AS CHAR(4)) Description
     ,COUNT(*) Transactions
     ,Usd
     ,0 + Usd
    FROM dbo.ProviderCommissionPayments
    INNER JOIN ProviderCommissionPaymentTypes pt
      ON pt.ProviderCommissionPaymentTypeId = dbo.ProviderCommissionPayments.ProviderCommissionPaymentTypeId
    WHERE dbo.ProviderCommissionPayments.AgencyId = @AgencyId
    AND dbo.ProviderCommissionPayments.ProviderId = @ProviderId
    AND (dbo.[fn_GetNextDayPeriod](Year, Month) >= CAST(@FromDate AS DATE)
        OR @FromDate IS NULL)
        AND (dbo.[fn_GetNextDayPeriod](Year, Month) <= CAST(@ToDate AS DATE)
        OR @ToDate IS NULL) 
    AND pt.Code = 'CODE08'  
    GROUP BY 
--    CAST(dbo.ProviderCommissionPayments.AdjustmentDate AS DATE)
             dbo.ProviderCommissionPayments.MONTH
            ,dbo.ProviderCommissionPayments.Year
            ,Usd


 INSERT INTO @result
    SELECT
      27
--     ,'COMMISSION' AS Type
     ,'PAYMENT' AS Type
     ,dbo.[fn_GetNextDayPeriod](Year, Month) AS CreationDate
     ,'CLOSING COMISSION (BALANCE MANUAL) '  Description
     ,COUNT(*) Transactions
     ,Usd
     ,0 - Usd
    FROM dbo.ProviderCommissionPayments
    INNER JOIN ProviderCommissionPaymentTypes pt
      ON pt.ProviderCommissionPaymentTypeId = dbo.ProviderCommissionPayments.ProviderCommissionPaymentTypeId
    WHERE dbo.ProviderCommissionPayments.AgencyId = @AgencyId
    AND dbo.ProviderCommissionPayments.ProviderId = @ProviderId
    AND (dbo.[fn_GetNextDayPeriod](Year, Month) >= CAST(@FromDate AS DATE)
        OR @FromDate IS NULL)
        AND (dbo.[fn_GetNextDayPeriod](Year, Month) <= CAST(@ToDate AS DATE)
        OR @ToDate IS NULL) 
    AND pt.Code = 'CODE08'  
    GROUP BY 
--    CAST(dbo.ProviderCommissionPayments.AdjustmentDate AS DATE)
             dbo.ProviderCommissionPayments.MONTH
            ,dbo.ProviderCommissionPayments.Year
            ,Usd

  RETURN;
END;
GO