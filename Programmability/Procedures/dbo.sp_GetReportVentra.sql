SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:20-09-2023
--CAMBIOS EN 5377,Refactorizacion de reporte ventra

CREATE PROCEDURE [dbo].[sp_GetReportVentra]
(@AgencyId INT, 
 @FromDate DATETIME = NULL, 
 @ToDate   DATETIME = NULL, 
 @Date     DATETIME
)
AS
    BEGIN
        IF(@FromDate IS NULL)
            BEGIN
                SET @FromDate = DATEADD(day, -10, @Date);
                SET @ToDate = @Date;
        END;


	-- INITIAL BALANCE

  DECLARE @initialBalanceFinalDate DATETIME
  SET @initialBalanceFinalDate = DATEADD(day, -1, @FromDate)
  DECLARE @Cost DECIMAL(18,2)
  DECLARE @Commission DECIMAL(18,2)
  SET @Cost = ISNULL((SELECT SUM(CAST(BalanceCost AS DECIMAL(18,2))) FROM dbo.FN_GenerateVentraReport(@AgencyId, '1985-01-01', @initialBalanceFinalDate)),0)
  SET @Commission = ISNULL((SELECT SUM(CAST(Commission AS DECIMAL(18,2))) FROM dbo.FN_GenerateVentraReport(@AgencyId, '1985-01-01', @initialBalanceFinalDate)),0)
--  SET @Commission = ISNULL((dbo.fn_CalculateVentraInitialBalanceCommission(@AgencyId,  '1985-01-01', @initialBalanceFinalDate)),0)
		
  CREATE TABLE #Temp 
  (
           [ID] INT IDENTITY(1,1),
           [Index]        INT, 
           [Type]         VARCHAR(100), 
           [CreationDate] DATETIME, 
           [Description]  VARCHAR(300), 
           Cost             DECIMAL(18, 2) NULL, 
           Commission       DECIMAL(18, 2) NULL, 
           CreditCost       DECIMAL(18, 2) NULL, 
           CreditCommission DECIMAL(18, 2) NULL, 
           [Month]          INT NULL, 
           [Year]           INT NULL,      BalanceCost             DECIMAL(18, 2) NULL
               
  )


  		INSERT INTO #Temp
                 SELECT 0 [Index], 
                        'INITIAL BALANCE' Type, 
                        CAST(@initialBalanceFinalDate AS DATE) CreationDate, 
                        'INITIAL BALANCE' Description, 
                        ISNULL(@Cost, 0) Cost, 
                        ISNULL(@Commission, 0) Commission,
                        NULL, 
                        NULL, 
                        NULL, 
                        NULL,
                        ISNULL(@Cost, 0) BalanceCost
  			
         UNION ALL

          SELECT *
          FROM [dbo].FN_GenerateVentraReport(@AgencyId, @FromDate, @ToDate)
          ORDER BY CreationDate, 
                   [Index];
  
  				
  				
  				SELECT 
  				 *,
  				 (
              SELECT ISNULL( SUM(CAST(BalanceCost AS DECIMAL(18,2))), 0)
              FROM    #Temp T2
              WHERE T2.ID <= T1.ID
          ) RunningSumCost,
          	 (
              SELECT ISNULL(SUM(Commission),0)
              FROM    #Temp T2
              WHERE T2.ID <= T1.ID
          ) RunningSumCommision
  				 FROM #Temp T1
  
  				 DROP TABLE #Temp

--- funcion de cost contiene todo lo relacionado a las consultas
--- funcion de commision sigue igual
---------OLD SP
--        CREATE TABLE #Temp
--        ([Index]          INT, 
--         [Type]           VARCHAR(30), 
--         CreationDate     DATETIME, 
--         [Description]    VARCHAR(100), 
--         Cost             DECIMAL(18, 2) NULL, 
--         Commission       DECIMAL(18, 2) NULL, 
--         CreditCost       DECIMAL(18, 2) NULL, 
--         CreditCommission DECIMAL(18, 2) NULL, 
--         [Month]          INT NULL, 
--         [Year]           INT NULL
--        );
--
--        -- Initial cash balance
--        INSERT INTO #Temp
--               SELECT 1, 
--                      'INITIAL BALANCE', 
--                      CAST(@FromDate AS DATE), 
--                      'INITIAL BALANCE', 
--                      dbo.fn_CalculateVentraInitialBalanceCost(@AgencyId, @FromDate), 
--                      dbo.fn_CalculateVentraInitialBalanceCommission(@AgencyId, @FromDate), 
--                      NULL, 
--                      NULL, 
--                      NULL, 
--                      NULL;
--
--        -- Daily
--
--        INSERT INTO #Temp
--               SELECT 2, 
--                      t.Type, 
--                      t.CreationDate, 
--                      t.Description, 
--                      SUM(t.Usd), 
--                      SUM(t.Commission), 
--                      NULL, 
--                      NULL, 
--                      NULL, 
--                      NULL
--               FROM
--               (
--                   SELECT 'DAILY' AS Type, 
--                          CAST(dbo.Ventra.CreationDate AS DATE) AS CreationDate, 
--                          'CLOSING DAILY' AS Description, 
--                          ISNULL(dbo.Ventra.ReloadUsd, 0) -  (ISNULL(dbo.Ventra.ReloadUsd, 0) * ISNULL(dbo.Ventra.Commission, 0) / 100) AS Usd, 
--                          (ISNULL(dbo.Ventra.ReloadUsd, 0) * ISNULL(dbo.Ventra.Commission, 0) / 100) AS Commission
--                   FROM dbo.Ventra
--                   WHERE dbo.Ventra.AgencyId = @AgencyId
--                         AND CAST(dbo.Ventra.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
--                         AND CAST(dbo.Ventra.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
--               ) t
--               GROUP BY t.CreationDate, 
--                        t.Type, 
--                        t.Description;
--
--        -- Bank payments credit
--
--        INSERT INTO #Temp
--               SELECT 3, 
--                      'BANK PAYMENT' AS Type, 
--                      CAST(dbo.ConciliationVentras.Date AS DATE) AS CreationDate, 
--                     '*** ' + dbo.BankAccounts.AccountNumber + ' (' + dbo.Bank.Name + ')' Description,
--                      NULL, 
--                      NULL, 
--                      ISNULL(dbo.ConciliationVentras.Usd, 0) AS Usd, 
--                      NULL, 
--                      NULL, 
--                      NULL
--               FROM dbo.ConciliationVentras INNER JOIN 
--			   	dbo.BankAccounts ON dbo.BankAccounts.BankAccountId = dbo.ConciliationVentras.BankAccountId INNER JOIN
--					dbo.Bank ON dbo.Bank.BankId = dbo.BankAccounts.BankId
--               WHERE dbo.ConciliationVentras.AgencyId = @AgencyId
--                     AND CAST(dbo.ConciliationVentras.Date AS DATE) >= CAST(@FromDate AS DATE)
--                     AND CAST(dbo.ConciliationVentras.Date AS DATE) <= CAST(@ToDate AS DATE)
--                     AND dbo.ConciliationVentras.IsCredit = 1;
--
--        -- Bank payments debit
--
--        INSERT INTO #Temp
--               SELECT 4, 
--                      'BANK PAYMENT' AS Type, 
--                      CAST(dbo.ConciliationVentras.Date AS DATE) AS CreationDate, 
--                     '*** ' + dbo.BankAccounts.AccountNumber + ' (' + dbo.Bank.Name + ')' Description,
--                      ISNULL(dbo.ConciliationVentras.Usd, 0) AS Usd, 
--                      NULL, 
--                      NULL, 
--                      NULL, 
--                      NULL, 
--                      NULL
--               FROM dbo.ConciliationVentras INNER JOIN 
--			   	dbo.BankAccounts ON dbo.BankAccounts.BankAccountId = dbo.ConciliationVentras.BankAccountId INNER JOIN
--					dbo.Bank ON dbo.Bank.BankId = dbo.BankAccounts.BankId
--               WHERE dbo.ConciliationVentras.AgencyId = @AgencyId
--                     AND CAST(dbo.ConciliationVentras.Date AS DATE) >= CAST(@FromDate AS DATE)
--                     AND CAST(dbo.ConciliationVentras.Date AS DATE) <= CAST(@ToDate AS DATE)
--                     AND dbo.ConciliationVentras.IsCredit = 0;
--
--        -- Cash payments (credit)
--
--        INSERT INTO #Temp
--               SELECT 5, 
--                      'PAYMENTS', 
--                      CAST(dbo.PaymentCash.Date AS DATE), 
--                      'CASH PAYMENTS', 
--                      NULL, 
--                      NULL, 
--                      ISNULL(dbo.PaymentCash.USD, 0), 
--                      NULL, 
--                      NULL, 
--                      NULL
--               FROM dbo.PaymentCash
--                    INNER JOIN dbo.Providers ON dbo.PaymentCash.ProviderId = dbo.Providers.ProviderId
--                    INNER JOIN dbo.ProviderTypes ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
--               WHERE (DeletedOn is null AND DeletedBy IS NULL AND Status != @PaymentOthersStatusId) AND 
--               dbo.PaymentCash.AgencyId = @AgencyId
--                     AND CAST(dbo.PaymentCash.Date AS DATE) >= CAST(@FromDate AS DATE)
--                     AND CAST(dbo.PaymentCash.Date AS DATE) <= CAST(@ToDate AS DATE)
--                     AND dbo.ProviderTypes.Code = 'C20';--Ventra
-- -- Other payments (credit)
--
--        INSERT INTO #Temp
--               SELECT 7, 
--                      'PAYMENTS', 
--                      CAST(dbo.PaymentOthers.Date AS DATE), 
--                      'OTHER PAYMENTS CREDIT', 
--                      NULL, 
--                      NULL, 
--                      ISNULL(dbo.PaymentOthers.USD, 0), 
--                      NULL, 
--                      NULL, 
--                      NULL
--               FROM dbo.PaymentOthers
--                    INNER JOIN dbo.Providers ON dbo.PaymentOthers.ProviderId = dbo.Providers.ProviderId
--                    INNER JOIN dbo.ProviderTypes ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
--               WHERE (DeletedOn is null AND DeletedBy IS NULL AND PaymentOtherStatusId != @PaymentOthersStatusId) AND 
--               dbo.PaymentOthers.AgencyId = @AgencyId
--                     AND CAST(dbo.PaymentOthers.Date AS DATE) >= CAST(@FromDate AS DATE)
--                     AND CAST(dbo.PaymentOthers.Date AS DATE) <= CAST(@ToDate AS DATE)
--                     AND dbo.ProviderTypes.Code = 'C20'--Ventra
--                     AND PaymentOthers.isDebit = 1
---- Other payments (debit)
--
--        INSERT INTO #Temp
--               SELECT 8, 
--                      'PAYMENTS', 
--                      CAST(dbo.PaymentOthers.Date AS DATE), 
--                      'OTHER PAYMENTS DEBIT', 
--                       ISNULL(dbo.PaymentOthers.USD, 0), 
--                      NULL, 
--                      NULL, 
--                      NULL,
--                      NULL, 
--                     
--                      NULL
--               FROM dbo.PaymentOthers
--                    INNER JOIN dbo.Providers ON dbo.PaymentOthers.ProviderId = dbo.Providers.ProviderId
--                    INNER JOIN dbo.ProviderTypes ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
--               WHERE (DeletedOn is null AND DeletedBy IS NULL AND PaymentOtherStatusId != @PaymentOthersStatusId) AND 
--               dbo.PaymentOthers.AgencyId = @AgencyId
--                     AND CAST(dbo.PaymentOthers.Date AS DATE) >= CAST(@FromDate AS DATE)
--                     AND CAST(dbo.PaymentOthers.Date AS DATE) <= CAST(@ToDate AS DATE)
--                     AND dbo.ProviderTypes.Code = 'C20'--Ventra
--                     AND PaymentOthers.isDebit = 0
--
--        -- Commissions
--
--        INSERT INTO #Temp
--               SELECT 6, 
--                      'COMMISSIONS', 
--                      CAST(dbo.ProviderCommissionPayments.CreationDate AS DATE), 
--                      'COMMISSIONS ', 
--                      NULL, 
--                      NULL, 
--                      NULL, 
--                      Usd, 
--                      dbo.ProviderCommissionPayments.Month, 
--                      dbo.ProviderCommissionPayments.Year
--               FROM dbo.ProviderCommissionPayments
--                    INNER JOIN dbo.Providers ON dbo.ProviderCommissionPayments.ProviderId = dbo.Providers.ProviderId
--                    INNER JOIN dbo.ProviderTypes ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
--               WHERE dbo.ProviderTypes.Code = 'C20'
--                     AND dbo.ProviderCommissionPayments.AgencyId = @AgencyId
--                     AND CAST(dbo.ProviderCommissionPayments.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
--                     AND CAST(dbo.ProviderCommissionPayments.CreationDate AS DATE) <= CAST(@ToDate AS DATE);
--        SELECT *
--        FROM #Temp
--        ORDER BY CreationDate, 
--                 [Index];
--        DROP TABLE #Temp;
    END;







GO