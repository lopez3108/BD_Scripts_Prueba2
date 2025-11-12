SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:24-10-2023
--CAMBIOS EN 5463, cambiar fecha de  pago de comisiones

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:19-09-2023
--CAMBIOS EN 5377,Refactorizacion de reporte ventra

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:22-09-2023
--CAMBIOS EN 5398, Registros del modulo Concilliation deben hacer la operacion inversa en reportes

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:09-10-2023
--CAMBIOS EN 5425 (NO DEBE DE MOSTRAR EL VALOR CONTABLE INVERSO SOLO PARA ESTE REPORTE)
CREATE FUNCTION [dbo].[FN_GenerateVentraReport] (@AgencyId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL)
RETURNS @result TABLE (
  [Index] INT
 ,[Type] VARCHAR(100)
 ,[CreationDate] DATETIME
 ,[Description] VARCHAR(300)
 ,Cost DECIMAL(18, 2) NULL
 ,Commission DECIMAL(18, 2) NULL
 ,CreditCost DECIMAL(18, 2) NULL
 ,CreditCommission DECIMAL(18, 2) NULL
 ,[Month] INT NULL
 ,[Year] INT NULL
 ,BalanceCost DECIMAL(18, 2) NULL
)


AS
BEGIN
  -- ESTADO DELETE OTHER Y CASH
  DECLARE @PaymentOthersStatusId INT;
  SET @PaymentOthersStatusId = (SELECT TOP 1
      pos.PaymentOtherStatusId
    FROM PaymentOthersStatus pos
    WHERE pos.Code = 'C03')
  -- Daily

  INSERT INTO @result
    SELECT
      2
     ,t.Type
     ,t.CreationDate
     ,t.Description
     ,ISNULL(SUM(t.Usd), 0)
     ,ISNULL(SUM(t.Commission), 0)
     ,NULL
     ,NULL
     ,NULL
     ,NULL
     ,0 - ISNULL(SUM(t.Usd), 0)
    FROM (SELECT
        'DAILY' AS Type
       ,CAST(dbo.Ventra.CreationDate AS DATE) AS CreationDate
       ,'CLOSING DAILY' AS Description
       ,ISNULL(dbo.Ventra.ReloadUsd, 0) - (ISNULL(dbo.Ventra.ReloadUsd, 0) * ISNULL(dbo.Ventra.Commission, 0) / 100) AS Usd
       ,(ISNULL(dbo.Ventra.ReloadUsd, 0) * ISNULL(dbo.Ventra.Commission, 0) / 100) AS Commission
      FROM dbo.Ventra
      WHERE dbo.Ventra.AgencyId = @AgencyId
      AND CAST(dbo.Ventra.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
      AND CAST(dbo.Ventra.CreationDate AS DATE) <= CAST(@ToDate AS DATE)) t
    GROUP BY t.CreationDate
            ,t.Type
            ,t.Description;


  -- Bank payments credit

  INSERT INTO @result
    SELECT
      4
     ,'BANK PAYMENT' AS Type
     ,CAST(dbo.ConciliationVentras.Date AS DATE) AS CreationDate
     ,'*** ' + dbo.BankAccounts.AccountNumber + ' (' + dbo.Bank.Name + ')' Description
     ,ISNULL(dbo.ConciliationVentras.Usd, 0) AS Usd
     ,NULL
     ,NULL
     ,NULL
     ,NULL
     ,NULL
     ,0 - ISNULL(dbo.ConciliationVentras.Usd, 0)
    FROM dbo.ConciliationVentras
    INNER JOIN dbo.BankAccounts
      ON dbo.BankAccounts.BankAccountId = dbo.ConciliationVentras.BankAccountId
    INNER JOIN dbo.Bank
      ON dbo.Bank.BankId = dbo.BankAccounts.BankId
    WHERE dbo.ConciliationVentras.AgencyId = @AgencyId
    AND CAST(dbo.ConciliationVentras.Date AS DATE) >= CAST(@FromDate AS DATE)
    AND CAST(dbo.ConciliationVentras.Date AS DATE) <= CAST(@ToDate AS DATE)
    AND dbo.ConciliationVentras.IsCredit = 1;
  --        -- Bank payments debit
  --
  INSERT INTO @result
    SELECT
      3
     ,'BANK PAYMENT' AS Type
     ,CAST(dbo.ConciliationVentras.Date AS DATE) AS CreationDate
     ,'*** ' + dbo.BankAccounts.AccountNumber + ' (' + dbo.Bank.Name + ')' Description
     ,NULL
     ,NULL
     ,ISNULL(dbo.ConciliationVentras.Usd, 0) AS Usd
     ,NULL
     ,NULL
     ,NULL
     ,0 + ISNULL(dbo.ConciliationVentras.Usd, 0)
    FROM dbo.ConciliationVentras
    INNER JOIN dbo.BankAccounts
      ON dbo.BankAccounts.BankAccountId = dbo.ConciliationVentras.BankAccountId
    INNER JOIN dbo.Bank
      ON dbo.Bank.BankId = dbo.BankAccounts.BankId
    WHERE dbo.ConciliationVentras.AgencyId = @AgencyId
    AND CAST(dbo.ConciliationVentras.Date AS DATE) >= CAST(@FromDate AS DATE)
    AND CAST(dbo.ConciliationVentras.Date AS DATE) <= CAST(@ToDate AS DATE)
    AND dbo.ConciliationVentras.IsCredit = 0;
  --
  --        -- Cash payments (credit)
  --
  INSERT INTO @result
    SELECT
      5
     ,'PAYMENTS'
     ,CAST(dbo.PaymentCash.Date AS DATE)
     ,'CASH PAYMENTS'
     ,NULL
     ,NULL
     ,ISNULL(dbo.PaymentCash.USD, 0)
     ,NULL
     ,NULL
     ,NULL
     ,0 + ISNULL(dbo.PaymentCash.USD, 0)
    FROM dbo.PaymentCash
    INNER JOIN dbo.Providers
      ON dbo.PaymentCash.ProviderId = dbo.Providers.ProviderId
    INNER JOIN dbo.ProviderTypes
      ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
    WHERE (DeletedOn IS NULL
    AND DeletedBy IS NULL
    AND Status != @PaymentOthersStatusId)
    AND dbo.PaymentCash.AgencyId = @AgencyId
    AND CAST(dbo.PaymentCash.Date AS DATE) >= CAST(@FromDate AS DATE)
    AND CAST(dbo.PaymentCash.Date AS DATE) <= CAST(@ToDate AS DATE)
    AND dbo.ProviderTypes.Code = 'C20';--Ventra
  -- -- Other payments (credit)
  --
  INSERT INTO @result
    SELECT
      7
     ,'PAYMENTS'
     ,CAST(dbo.PaymentOthers.Date AS DATE)
     ,'OTHER PAYMENTS CREDIT'
     ,NULL
     ,NULL
     ,ISNULL(dbo.PaymentOthers.USD, 0)
     ,NULL
     ,NULL
     ,NULL
     ,0 - ISNULL(dbo.PaymentOthers.USD, 0)
    FROM dbo.PaymentOthers
    INNER JOIN dbo.Providers
      ON dbo.PaymentOthers.ProviderId = dbo.Providers.ProviderId
    INNER JOIN dbo.ProviderTypes
      ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
    WHERE (DeletedOn IS NULL
    AND DeletedBy IS NULL
    AND PaymentOtherStatusId != @PaymentOthersStatusId)
    AND dbo.PaymentOthers.AgencyId = @AgencyId
    AND CAST(dbo.PaymentOthers.Date AS DATE) >= CAST(@FromDate AS DATE)
    AND CAST(dbo.PaymentOthers.Date AS DATE) <= CAST(@ToDate AS DATE)
    AND dbo.ProviderTypes.Code = 'C20'--Ventra
    AND PaymentOthers.IsDebit = 1
  ---- Other payments (debit)
  --
  INSERT INTO @result
    SELECT
      8
     ,'PAYMENTS'
     ,CAST(dbo.PaymentOthers.Date AS DATE)
     ,'OTHER PAYMENTS DEBIT'
     ,ISNULL(dbo.PaymentOthers.USD, 0)
     ,NULL
     ,NULL
     ,NULL
     ,NULL
     ,NULL
     ,0 + ISNULL(dbo.PaymentOthers.USD, 0)
    FROM dbo.PaymentOthers
    INNER JOIN dbo.Providers
      ON dbo.PaymentOthers.ProviderId = dbo.Providers.ProviderId
    INNER JOIN dbo.ProviderTypes
      ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
    WHERE (DeletedOn IS NULL
    AND DeletedBy IS NULL
    AND PaymentOtherStatusId != @PaymentOthersStatusId)
    AND dbo.PaymentOthers.AgencyId = @AgencyId
    AND CAST(dbo.PaymentOthers.Date AS DATE) >= CAST(@FromDate AS DATE)
    AND CAST(dbo.PaymentOthers.Date AS DATE) <= CAST(@ToDate AS DATE)
    AND dbo.ProviderTypes.Code = 'C20'--Ventra
    AND PaymentOthers.IsDebit = 0
  --
  --        -- Commissions
  --
  INSERT INTO @result
    SELECT
      6
     ,'COMMISSIONS'
     ,dbo.[fn_GetNextDayPeriod](Year, Month)
      --                      CAST(dbo.ProviderCommissionPayments.CreationDate AS DATE), 
     ,'COMM. ' + dbo.[fn_GetMonthByNum](Month) + '-' + CAST(Year AS CHAR(4)) Description
     ,NULL
     ,-USD --Se cambió de  NULL A USD la task 5611 La comisión esta afectando el BALANCE COST y debe afectar BALANCE COMMISSION
     ,NULL
     ,USD
     ,dbo.ProviderCommissionPayments.Month
     ,dbo.ProviderCommissionPayments.Year
     ,NULL --Se cambió de  ,0 - USD a null según la task 5611 La comisión esta afectando el BALANCE COST y debe afectar BALANCE COMMISSION
    FROM dbo.ProviderCommissionPayments
    INNER JOIN dbo.Providers
      ON dbo.ProviderCommissionPayments.ProviderId = dbo.Providers.ProviderId
    INNER JOIN dbo.ProviderTypes
      ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
    WHERE dbo.ProviderTypes.Code = 'C20'
    AND dbo.ProviderCommissionPayments.AgencyId = @AgencyId
    AND (dbo.[fn_GetNextDayPeriod](Year, Month) >= CAST(@FromDate AS DATE)
    OR @FromDate IS NULL)
    AND (dbo.[fn_GetNextDayPeriod](Year, Month) <= CAST(@ToDate AS DATE)
    OR @ToDate IS NULL)

  -----


  RETURN;
END;
GO