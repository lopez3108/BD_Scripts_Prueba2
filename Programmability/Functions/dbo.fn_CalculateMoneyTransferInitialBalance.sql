SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:19-09-2023
--CAMBIOS EN 5366, cambios en consultas de cash payment y other payment.
CREATE FUNCTION [dbo].[fn_CalculateMoneyTransferInitialBalance](@AgencyId       INT,
                                                               @ProviderId     INT,
                                                               @EndDate        DATETIME = NULL,
                                                               @GetCurrentDate BIT      = 0)
RETURNS DECIMAL(18, 2)
AS
     BEGIN
         IF(@GetCurrentDate = 1)
             BEGIN
                 SET @EndDate = DATEADD(DAY, 1, @EndDate);
         END;
         --ESTADO DELETE OTHER Y CASH
  DECLARE @PaymentOthersStatusId INT ;
  SET @PaymentOthersStatusId = (SELECT TOP 1
      pos.PaymentOtherStatusId
    FROM PaymentOthersStatus pos
    WHERE pos.Code = 'C03')
         RETURN((
		  ---- INITIAL BALANCE
	   ISNULL((SELECT TOP 1 InitialBalance
                   FROM MoneyTransferxAgencyInitialBalances
                 
                   WHERE AgencyId = @AgencyId
                         AND ProviderId = @providerId),0)
+
		 --Comienzo sumas
(
 --Payment cash

        +( ISNULL((
                SELECT SUM(dbo.PaymentCash.USD) as Usd
                FROM dbo.PaymentCash
                     INNER JOIN dbo.Providers ON dbo.PaymentCash.ProviderId = dbo.Providers.ProviderId
                WHERE (DeletedOn is null AND DeletedBy IS NULL AND Status != @PaymentOthersStatusId) AND
                CAST(dbo.PaymentCash.Date AS DATE) < CAST(@EndDate AS DATE)
                      AND dbo.PaymentCash.AgencyId = @AgencyId
                      AND dbo.PaymentCash.ProviderId = @ProviderId),0)

-- Adjustment to

        + ISNULL((
                SELECT SUM(USD)
                FROM dbo.PaymentAdjustment
				INNER JOIN MoneyTransferxAgencyNumbers ON
				MoneyTransferxAgencyNumbers.AgencyId = dbo.PaymentAdjustment.AgencyToId 
				AND MoneyTransferxAgencyNumbers.ProviderId = dbo.PaymentAdjustment.ProviderId AND AgencyToId = @AgencyId
				AND MoneyTransferxAgencyNumbers.ProviderId = @ProviderId
                WHERE 
						AgencyToId = @AgencyId
                      AND CAST(dbo.PaymentAdjustment.Date AS DATE) < CAST(@EndDate AS DATE)
					  AND PaymentAdjustment.DeletedBy IS NULL 
					  AND PaymentAdjustment.DeletedOn IS NULL),0)
				)


 --Checks
         + ISNULL((
                SELECT SUM(Usd)
              FROM dbo.PaymentChecksAgentToAgent
                WHERE ToAgency = @AgencyId
                      AND ProviderId = @ProviderId
                      AND CAST(dbo.PaymentChecksAgentToAgent.Date AS DATE) < CAST(@EndDate AS DATE)),0)

					



 -- Payment checks

         + ISNULL((
                SELECT 
                       SUM(t.Usd)
                FROM
                (
                    SELECT 'PAYMENT CHECKS' AS Type,
                           CAST(pc.Date AS DATE) AS CreationDate,
                           dbo.Agencies.Code+' '+CASE
                                                                              WHEN dbo.ProviderTypes.Code = 'C02'
                                                                              THEN ISNULL(
                                                                                         (
                                                                                             SELECT TOP 1 mt.Number
                                                                                             FROM MoneyTransferxAgencyNumbers mt
                                                                                             WHERE mt.AgencyId = pc.AgencyId
                                                                                                   AND mt.ProviderId = pc.ProviderId
                                                                                         ), 'Not registered')
                                                                              ELSE dbo.Providers.Name
                                                                          END+' '+CAST(CONVERT(VARCHAR, pc.FromDate, 110) AS VARCHAR(10))+' TO '+CAST(CONVERT(VARCHAR, pc.ToDate, 110) AS VARCHAR(10)) AS Description,
                           Usd AS Usd
                    FROM dbo.PaymentChecks pc
                         INNER JOIN dbo.Agencies ON pc.AgencyId = dbo.Agencies.AgencyId
                         INNER JOIN dbo.Providers ON pc.ProviderId = dbo.Providers.ProviderId
                         INNER JOIN dbo.ProviderTypes ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
                    WHERE((@EndDate IS NULL)
                              OR (CAST([Date] AS DATE) < CAST(@EndDate AS DATE)))
                         AND pc.AgencyId = @AgencyId
                         AND pc.ProviderId = @ProviderId
                ) t),0)




-- Payment other (credit)

       + ISNULL((
                SELECT SUM(USD)
                FROM dbo.PaymentOthers
                WHERE (DeletedOn is null AND DeletedBy IS NULL AND PaymentOtherStatusId != @PaymentOthersStatusId) AND
                AgencyId = @AgencyId
                      AND ProviderId = @ProviderId
                      AND IsDebit = 0
                      AND CAST(dbo.PaymentOthers.Date AS DATE) < CAST(@EndDate AS DATE)),0)

 

-- Cancellation
       + ISNULL((
                SELECT SUM(((TotalTransaction + Fee) * -1))
                FROM dbo.Cancellations
                     INNER JOIN dbo.Providers ON dbo.Cancellations.ProviderCancelledId = dbo.Providers.ProviderId
                     INNER JOIN dbo.ProviderTypes ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
                     LEFT JOIN dbo.CancellationTypes ON dbo.CancellationTypes.CancellationTypeId = dbo.Cancellations.CancellationTypeId
                WHERE AgencyId = @AgencyId
                      AND ProviderCancelledId = @ProviderId
                      AND CAST(dbo.Cancellations.CancellationDate AS DATE) < CAST(@EndDate AS DATE)),0)

 --Money distribution

         + ISNULL((SELECT SUM(dbo.DailyDistribution.Usd)
               FROM dbo.DailyDistribution
                     INNER JOIN dbo.Daily ON dbo.DailyDistribution.DailyId = dbo.Daily.DailyId
                     INNER JOIN dbo.Agencies ON dbo.Daily.AgencyId = dbo.Agencies.AgencyId
                     INNER JOIN dbo.Agencies AS Agencies_1 ON dbo.DailyDistribution.AgencyId = Agencies_1.AgencyId
                     INNER JOIN dbo.Providers ON dbo.DailyDistribution.ProviderId = dbo.Providers.ProviderId
                     INNER JOIN dbo.Cashiers ON dbo.Daily.CashierId = dbo.Cashiers.CashierId
                     INNER JOIN dbo.Users ON dbo.Cashiers.UserId = dbo.Users.UserId
                WHERE dbo.DailyDistribution.AgencyId = @AgencyId
                      AND dbo.DailyDistribution.ProviderId = @ProviderId
                      AND CAST(dbo.Daily.CreationDate AS DATE) < CAST(@EndDate AS DATE)),0)


-- Cash agent to agent

        + ISNULL((
                SELECT SUM (USD)
                FROM dbo.PaymentCashAgentToAgent
                WHERE dbo.PaymentCashAgentToAgent.AgencyId = @AgencyId
                      AND dbo.PaymentCashAgentToAgent.ProviderId = @ProviderId
                      AND CAST(dbo.PaymentCashAgentToAgent.Date AS DATE) < CAST(@EndDate AS DATE)),0)

-- Commission payment  'ADJUSTMENT'
        + ISNULL((
                SELECT SUM(Usd)
                FROM dbo.ProviderCommissionPayments
                     INNER JOIN ProviderCommissionPaymentTypes pt ON pt.ProviderCommissionPaymentTypeId = dbo.ProviderCommissionPayments.ProviderCommissionPaymentTypeId
                WHERE dbo.ProviderCommissionPayments.AgencyId = @AgencyId
                      AND dbo.ProviderCommissionPayments.ProviderId = @ProviderId
                      AND CAST(dbo.ProviderCommissionPayments.CreationDate AS DATE) < CAST(@EndDate AS DATE)
                      AND pt.Code = 'CODE04'),0)
			
			--BANK PAYMENT DEBIT
			+ ISNULL((
                SELECT SUM(Usd)
                FROM dbo.ConciliationMoneyTransfers INNER JOIN
					dbo.BankAccounts ON dbo.BankAccounts.BankAccountId = dbo.ConciliationMoneyTransfers.BankAccountId INNER JOIN
					dbo.Bank ON dbo.Bank.BankId = dbo.BankAccounts.BankId
                WHERE IsCredit = 0 AND
						AgencyId = @AgencyId
                      AND ProviderId = @ProviderId
                      AND CAST(dbo.ConciliationMoneyTransfers.Date AS DATE) < CAST(@EndDate AS DATE)),0)


					  )
		-
       (--cominezo restas
	  

-- CLOSING DAILY M.T

        ISNULL(
                (SELECT 
                       (SUM(t.Usd)) AS Usd
                FROM
                (
                    SELECT 
                           SUM(ISNULL( dbo.MoneyTransfers.Usd, 0)) AS Usd
                    FROM dbo.Daily
                         INNER JOIN dbo.Cashiers ON dbo.Cashiers.CashierId = dbo.Daily.CashierId
                         INNER JOIN dbo.MoneyTransfers ON dbo.Daily.AgencyId = dbo.MoneyTransfers.AgencyId
                                                          AND CAST(dbo.MoneyTransfers.CreationDate AS DATE) = CAST(daily.CreationDate AS DATE)
                                                          AND dbo.Cashiers.UserId = dbo.MoneyTransfers.CreatedBy
                                                          AND dbo.MoneyTransfers.TotalTransactions > 0
                                                          AND dbo.MoneyTransfers.Transactions > 0
                         INNER JOIN dbo.Providers ON dbo.MoneyTransfers.ProviderId = dbo.Providers.ProviderId
                                                     --AND dbo.Providers.MoneyOrderService = 1 4600 se comento porque independientemente si el providers esta inactivo se debe de mostrar la operacion con este provider.
                    WHERE dbo.Daily.AgencyId = @AgencyId
					 --AND (dbo.MoneyTransfers.TotalTransactions <= 0 OR dbo.MoneyTransfers.TotalTransactions IS NULL )
                          AND CAST(dbo.Daily.CreationDate AS DATE) < CAST(@EndDate AS DATE)
                          AND dbo.MoneyTransfers.ProviderId = @ProviderId
                    GROUP BY CAST(dbo.Daily.CreationDate AS DATE)
                ) t),0)

	 --CLOSING DAILY M.O
        + ISNULL(
                (SELECT 
                       (SUM(t.Usd)) AS Usd
                FROM
                (
                    SELECT 
                           ABS(SUM((ISNULL(dbo.MoneyTransfers.UsdMoneyOrders, 0)) - (ISNULL(dbo.MoneyTransfers.MoneyOrderFee, 0)) * (ISNULL(dbo.MoneyTransfers.TransactionsNumberMoneyOrders, 0)))) AS Usd
                    FROM dbo.Daily
                         INNER JOIN dbo.Cashiers ON dbo.Cashiers.CashierId = dbo.Daily.CashierId
                         INNER JOIN dbo.MoneyTransfers ON MoneyTransfers.TransactionsNumberMoneyOrders > 0
                                                          AND dbo.Daily.AgencyId = dbo.MoneyTransfers.AgencyId
                                                          AND CAST(dbo.MoneyTransfers.CreationDate AS DATE) = CAST(daily.CreationDate AS DATE)
                                                          AND dbo.Cashiers.UserId = dbo.MoneyTransfers.CreatedBy
                         INNER JOIN dbo.Providers ON dbo.MoneyTransfers.ProviderId = dbo.Providers.ProviderId
--                                                     AND dbo.Providers.MoneyOrderService = 1 4600 se comento porque independientemente si el providers esta inactivo se debe de mostrar la operacion con este provider.
                    WHERE dbo.Daily.AgencyId = @AgencyId
                          AND CAST(dbo.Daily.CreationDate AS DATE) < CAST(@EndDate AS DATE)
                          AND dbo.MoneyTransfers.ProviderId = @ProviderId
                    GROUP BY CAST(dbo.Daily.CreationDate AS DATE),
					dbo.MoneyTransfers.MoneyTransfersId
                ) t),0)
					
	-- CLOSING DAILY M.O FEE
         + ISNULL((
                SELECT 
                       ABS(SUM(t.Usd)) AS Usd
                FROM
                (
                    SELECT 
                           ABS(SUM(ISNULL(dbo.MoneyTransfers.TransactionsNumberMoneyOrders, 0)) * SUM(ISNULL(dbo.MoneyTransfers.ProviderMoneyCommission, 0))) AS Usd
                    FROM dbo.Daily
                         INNER JOIN dbo.Cashiers ON dbo.Cashiers.CashierId = dbo.Daily.CashierId
                         INNER JOIN dbo.MoneyTransfers ON MoneyTransfers.TransactionsNumberMoneyOrders > 0
                                                          AND dbo.Daily.AgencyId = dbo.MoneyTransfers.AgencyId
                                                          AND CAST(dbo.MoneyTransfers.CreationDate AS DATE) = CAST(daily.CreationDate AS DATE)
                                                          AND dbo.Cashiers.UserId = dbo.MoneyTransfers.CreatedBy
                         INNER JOIN dbo.Providers ON dbo.MoneyTransfers.ProviderId = dbo.Providers.ProviderId
--                                                     AND dbo.Providers.MoneyOrderService = 1 4600 se comento porque independientemente si el providers esta inactivo se debe de mostrar la operacion con este provider.
                    WHERE dbo.Daily.AgencyId = @AgencyId
                          --AND Usd > 0
                          AND CAST(dbo.Daily.CreationDate AS DATE) < CAST(@EndDate AS DATE)
                          AND dbo.MoneyTransfers.ProviderId = @ProviderId
                    GROUP BY CAST(dbo.Daily.CreationDate AS DATE),
                             dbo.MoneyTransfers.MoneyTransfersId
                ) t
                WHERE T.Usd > 0),0)

				-- Adjustment from
         + ISNULL((
                SELECT SUM(USD)
                FROM dbo.PaymentAdjustment
                WHERE AgencyFromId = @AgencyId
                      AND ProviderId = @ProviderId
                      AND CAST(dbo.PaymentAdjustment.Date AS DATE) < CAST(@EndDate AS DATE)
					  AND dbo.PaymentAdjustment.DeletedBy IS NULL 
					  AND dbo.PaymentAdjustment.DeletedOn IS NULL),0)

					  -- Checks fee

        + ISNULL((
                SELECT   ABS(SUM(isnull(ProviderCheckfee * dbo.PaymentChecksAgentToAgent.NumberChecks, 0)))
                FROM dbo.PaymentChecksAgentToAgent
                WHERE ToAgency = @AgencyId
                      AND ProviderId = @ProviderId
                      AND CAST(dbo.PaymentChecksAgentToAgent.Date AS DATE) < CAST(@EndDate AS DATE)
                      AND Fee > 0),0)

					   -- Payment checks fee

         + ISNULL((
                SELECT SUM(t.Usd)
                FROM
                (
                    SELECT 
                           Fee AS Usd
                    FROM dbo.PaymentChecks pc
                         INNER JOIN dbo.Agencies ON pc.AgencyId = dbo.Agencies.AgencyId
                         INNER JOIN dbo.Providers ON pc.ProviderId = dbo.Providers.ProviderId
                         INNER JOIN dbo.ProviderTypes ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
                    WHERE((@EndDate IS NULL)
                              OR (CAST([Date] AS DATE) < CAST(@EndDate AS DATE)))
                         AND pc.AgencyId = @AgencyId
                         AND Fee > 0
                         AND pc.ProviderId = @ProviderId
                ) t),0)

				--Payment other (debit)

        + ISNULL((
                SELECT SUM (USD)
                FROM dbo.PaymentOthers
                WHERE (DeletedOn is null AND DeletedBy IS NULL AND PaymentOtherStatusId != @PaymentOthersStatusId) AND
                AgencyId = @AgencyId
                      AND ProviderId = @ProviderId
                      AND IsDebit = 1
                      AND CAST(dbo.PaymentOthers.Date AS DATE) < CAST(@EndDate AS DATE)),0)

-- Returned checks

         + ISNULL((
                SELECT SUM(USD)
                FROM dbo.ReturnedCheck
                WHERE ReturnedAgencyId = @AgencyId
                      AND ProviderId = @ProviderId
                      AND CAST(dbo.ReturnedCheck.ReturnDate AS DATE) < CAST(@EndDate AS DATE)),0)

-- Returned checks fee

         + ISNULL((
                SELECT SUM(ProviderFee)
                FROM dbo.ReturnedCheck
                WHERE ReturnedAgencyId = @AgencyId
                      AND ProviderId = @ProviderId
                      AND CAST(dbo.ReturnedCheck.ReturnDate AS DATE) < CAST(@EndDate AS DATE)),0)

					  		   --Concilliation money transfer bank payment

         + ISNULL((
                SELECT (SUM(Usd))
                FROM dbo.ConciliationMoneyTransfers INNER JOIN
					dbo.BankAccounts ON dbo.BankAccounts.BankAccountId = dbo.ConciliationMoneyTransfers.BankAccountId INNER JOIN
					dbo.Bank ON dbo.Bank.BankId = dbo.BankAccounts.BankId
                WHERE IsCredit = 1 AND
						AgencyId = @AgencyId
                      AND ProviderId = @ProviderId
                      AND CAST(dbo.ConciliationMoneyTransfers.Date AS DATE) < CAST(@EndDate AS DATE)),0)
				)--fin restas


-- Smart safe deposit
+ 

				ISNULL((select 
                       ABS(SUM(ABS(Usd))) as Usd
from SmartSafeDeposit s
WHERE 
						s.AgencyId = @AgencyId
                      AND ProviderId = @ProviderId
                      AND CAST(s.CreationDate AS DATE) < CAST(@EndDate AS DATE)),0)





					  ))












     END;

GO