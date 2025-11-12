SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:22-09-2023
--CAMBIOS EN 5398, Registros del modulo Concilliation deben hacer la operacion inversa en reportes

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:09-10-2023
--CAMBIOS EN 5425 (NO DEBE DE MOSTRAR EL VALOR CONTABLE INVERSO SOLO PARA ESTE REPORTE)
CREATE FUNCTION [dbo].[FN_GenerateTopUpPaymentsReport](
@AgencyId   INT, 
 @ProviderId INT, 
 @FromDate   DATETIME = NULL, 
 @ToDate     DATETIME = NULL, 
 @Date       DATETIME)
RETURNS @result TABLE
([Index]        INT, 
         [Type]         VARCHAR(100), 
         [CreationDate] DATETIME, 
         [Description]  VARCHAR(300), 
         [Debit]        DECIMAL(18, 2) NULL, 
         [Credit]       DECIMAL(18, 2) NULL,
		 [Balance]       DECIMAL(18, 2) NULL
		 
)
AS
     BEGIN

					-- Closing daily

        INSERT INTO @result
               SELECT 2, 
                      t.Type, 
                      t.CreationDate, 
                      t.Description, 
                      NULL, 
                      SUM(t.Usd) AS Usd,
					  0 - SUM(t.Usd)
               FROM
               (
                   SELECT 'CLOSING DAILY' AS Type, 
                          CAST(dbo.Daily.CreationDate AS DATE) AS CreationDate, 
                          'CLOSING DAILY' AS Description, 
                          ISNULL(dbo.BillPayments.Usd, 0) AS Usd
                   FROM dbo.Daily
                        INNER JOIN dbo.Cashiers ON dbo.Cashiers.CashierId = dbo.Daily.CashierId
                        INNER JOIN dbo.BillPayments ON dbo.Daily.AgencyId = dbo.BillPayments.AgencyId
                                                       AND CAST(billpayments.CreationDate AS DATE) = CAST(daily.CreationDate AS DATE)
                                                       AND dbo.Cashiers.UserId = billpayments.CreatedBy
                   WHERE dbo.Daily.AgencyId = @AgencyId
                         AND CAST(dbo.Daily.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                         AND CAST(dbo.Daily.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                         AND dbo.BillPayments.ProviderId = @ProviderId
               ) t
               GROUP BY t.CreationDate, 
                        t.Type, 
                        t.Description;

        -- Conciliation bill payment debit 5425 (NO DEBE DE MOSTRAR EL VALOR CONTABLE INVERSO SOLO PARA ESTE REPORTE)

        INSERT INTO @result 
               SELECT 3, 
                      'BANK PAYMENT DEBIT', 
                      CAST([Date] AS DATE), 
                      '*** ' + dbo.BankAccounts.AccountNumber + ' (' + dbo.Bank.Name + ')', 
                     
                     
                       dbo.ConciliationBillPayments.Usd,
					 NULL,
					   0 + dbo.ConciliationBillPayments.Usd
               FROM dbo.ConciliationBillPayments
                    INNER JOIN dbo.BankAccounts ON dbo.BankAccounts.BankAccountId = dbo.ConciliationBillPayments.BankAccountId
                    INNER JOIN dbo.Bank ON dbo.Bank.BankId = dbo.BankAccounts.BankId
               WHERE IsCredit = 0
                     AND AgencyId = @AgencyId
                     AND ProviderId = @ProviderId
                     AND CAST(dbo.ConciliationBillPayments.Date AS DATE) >= CAST(@FromDate AS DATE)
                     AND CAST(dbo.ConciliationBillPayments.Date AS DATE) <= CAST(@ToDate AS DATE);

        -- Conciliation bill payment credit (NO DEBE DE MOSTRAR EL VALOR CONTABLE INVERSO SOLO PARA ESTE REPORTE)


        INSERT INTO @result 
               SELECT 3, 
                      'BANK PAYMENT CREDIT', 
                      CAST([Date] AS DATE), 
                      '*** ' + dbo.BankAccounts.AccountNumber + ' (' + dbo.Bank.Name + ')', 
                    
                    NULL,
					    dbo.ConciliationBillPayments.Usd,
                
						 0 - dbo.ConciliationBillPayments.Usd
               FROM dbo.ConciliationBillPayments
                    INNER JOIN dbo.BankAccounts ON dbo.BankAccounts.BankAccountId = dbo.ConciliationBillPayments.BankAccountId
                    INNER JOIN dbo.Bank ON dbo.Bank.BankId = dbo.BankAccounts.BankId
               WHERE IsCredit = 1
                     AND AgencyId = @AgencyId
                     AND ProviderId = @ProviderId
                     AND CAST(dbo.ConciliationBillPayments.Date AS DATE) >= CAST(@FromDate AS DATE)
                     AND CAST(dbo.ConciliationBillPayments.Date AS DATE) <= CAST(@ToDate AS DATE);

        -- Payment cash

        INSERT INTO @result
               SELECT 4, 
                      'CASH PAYMENT' AS Type, 
                      dbo.PaymentCash.Date AS CreationDate, 
                      dbo.Providers.Name AS Description, 
                      dbo.PaymentCash.USD AS Usd, 
                      NULL,
					  0 + dbo.PaymentCash.USD
               FROM dbo.PaymentCash
                    INNER JOIN dbo.Providers ON dbo.PaymentCash.ProviderId = dbo.Providers.ProviderId
               WHERE CAST(dbo.PaymentCash.Date AS DATE) >= CAST(@FromDate AS DATE)
                     AND CAST(dbo.PaymentCash.Date AS DATE) <= CAST(@ToDate AS DATE)
                     AND dbo.PaymentCash.AgencyId = @AgencyId
                     AND dbo.PaymentCash.ProviderId = @ProviderId
                     AND dbo.PaymentCash.DeletedOn IS NULL;

        -- Payment other (credit)

        INSERT INTO @result
               SELECT 5, 
                      'PAYMENT OTHER DEBIT' AS Type, 
                      dbo.PaymentOthers.Date AS CreationDate, 
               (
                   SELECT TOP 1 Note
                   FROM NotesXPaymentOthers
                   WHERE PaymentOthers.PaymentOthersId = NotesXPaymentOthers.PaymentOthersId
               ) AS Description, 
                      NULL, 
                      USD AS Usd,
					  0 + USD
               FROM dbo.PaymentOthers
                    INNER JOIN PaymentOthersStatus PS ON PS.PaymentOtherStatusId = PaymentOthers.PaymentOtherStatusId
               WHERE AgencyId = @AgencyId
                     AND ProviderId = @ProviderId
                     AND IsDebit = 0
                     AND (PS.Code = 'C01'
                          OR PS.Code = 'C02')
                     AND CAST(dbo.PaymentOthers.Date AS DATE) >= CAST(@FromDate AS DATE)
                     AND CAST(dbo.PaymentOthers.Date AS DATE) <= CAST(@ToDate AS DATE);

        -- Payment other (debit)

        INSERT INTO @result
               SELECT 6, 
                      'PAYMENT OTHER CREDIT' AS Type, 
                      dbo.PaymentOthers.Date AS CreationDate, 
               (
                   SELECT TOP 1 Note
                   FROM NotesXPaymentOthers
                   WHERE PaymentOthers.PaymentOthersId = NotesXPaymentOthers.PaymentOthersId
               ) AS Description, 
                      USD AS Usd, 
                      NULL,
					  0 - USD
               FROM dbo.PaymentOthers
                    INNER JOIN PaymentOthersStatus PS ON PS.PaymentOtherStatusId = PaymentOthers.PaymentOtherStatusId
               WHERE AgencyId = @AgencyId
                     AND ProviderId = @ProviderId
                     AND IsDebit = 1
                     AND (PS.Code = 'C01'
                          OR PS.Code = 'C02')
                     AND CAST(dbo.PaymentOthers.Date AS DATE) >= CAST(@FromDate AS DATE)
                     AND CAST(dbo.PaymentOthers.Date AS DATE) <= CAST(@ToDate AS DATE);

        -- Checks

        INSERT INTO @result
               SELECT 7, 
                      'PROCESSED CHECKS' AS Type, 
                      dbo.PaymentChecksAgentToAgent.Date AS CreationDate, 
                      'FROM ' +
               (
                   SELECT TOP 1 Code 
                   FROM dbo.Agencies
                   WHERE dbo.Agencies.AgencyId = dbo.PaymentChecksAgentToAgent.FromAgency
               ) + ' TO ' +
               (
                   SELECT TOP 1 Code 
                   FROM dbo.Agencies
                   WHERE dbo.Agencies.AgencyId = dbo.PaymentChecksAgentToAgent.ToAgency
               ) +' BATCH #: '+ dbo.PaymentChecksAgentToAgent.providerBatch AS Description, 
                    
                      Usd,
                        NULL,
						0 + Usd
               FROM dbo.PaymentChecksAgentToAgent
               WHERE ToAgency = @AgencyId
                     AND ProviderId = @ProviderId
                     AND CAST(dbo.PaymentChecksAgentToAgent.Date AS DATE) >= CAST(@FromDate AS DATE)
                     AND CAST(dbo.PaymentChecksAgentToAgent.Date AS DATE) <= CAST(@ToDate AS DATE);

        -- Checks fee

        INSERT INTO @result
               SELECT 8, 
                      'PROCESSED CHECKS FEE' AS Type, 
                      dbo.PaymentChecksAgentToAgent.Date AS CreationDate, 
                      'FROM ' +
               (
                   SELECT TOP 1 Code + ' - ' + Name
                   FROM dbo.Agencies
                   WHERE dbo.Agencies.AgencyId = dbo.PaymentChecksAgentToAgent.FromAgency
               ) + ' TO ' +
               (
                   SELECT TOP 1 Code + ' - ' + Name
                   FROM dbo.Agencies
                   WHERE dbo.Agencies.AgencyId = dbo.PaymentChecksAgentToAgent.ToAgency
               ) AS Description, 
                NULL,
                      ProviderCheckfee * dbo.PaymentChecksAgentToAgent.NumberChecks AS Usd,
					  0 - (ProviderCheckfee * dbo.PaymentChecksAgentToAgent.NumberChecks)
                     
             FROM dbo.PaymentChecksAgentToAgent
               WHERE (ProviderCheckfee IS NOT NULL AND ProviderCheckfee > 0) AND
			   ToAgency = @AgencyId
                     AND ProviderId = @ProviderId
                     AND CAST(dbo.PaymentChecksAgentToAgent.Date AS DATE) >= CAST(@FromDate AS DATE)
                     AND CAST(dbo.PaymentChecksAgentToAgent.Date AS DATE) <= CAST(@ToDate AS DATE)
                     AND Fee > 0;

        -- Payment checks

        INSERT INTO @result
               SELECT 9, 
                      t.Type, 
                      t.CreationDate, 
                      t.Description, 
                      SUM(t.Usd) AS Usd,
                      NULL ,
					  0 - SUM(t.Usd)
                      
               FROM
               (
                   SELECT 'PAYMENT CHECKS' AS Type, 
                          CAST(pc.Date AS DATE) AS CreationDate, 
                          dbo.Agencies.Code + ' - ' + dbo.Agencies.Name + ' (' + CASE
                                                                                     WHEN dbo.ProviderTypes.Code = 'C02'
                                                                                     THEN ISNULL(
                   (
                       SELECT TOP 1 mt.Number
                       FROM MoneyTransferxAgencyNumbers mt
                       WHERE mt.AgencyId = pc.AgencyId
                             AND mt.ProviderId = pc.ProviderId
                   ), 'Number not registered')
                                                                                     ELSE dbo.Providers.Name
                                                                                 END + ') ' + CAST(CONVERT(VARCHAR, pc.FromDate, 110) AS VARCHAR(10)) + ' TO ' + CAST(CONVERT(VARCHAR, pc.ToDate, 110) AS VARCHAR(10)) AS Description, 
                          Usd AS Usd
                   FROM dbo.PaymentChecks pc
                        INNER JOIN dbo.Agencies ON pc.AgencyId = dbo.Agencies.AgencyId
                        INNER JOIN dbo.Providers ON pc.ProviderId = dbo.Providers.ProviderId
                        INNER JOIN dbo.ProviderTypes ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
                   WHERE((@FromDate IS NULL)
                         OR (CAST([Date] AS DATE) >= CAST(@FromDate AS DATE)))
                        AND ((@ToDate IS NULL)
                             OR (CAST([Date] AS DATE) <= CAST(@ToDate AS DATE)))
                        AND pc.AgencyId = @AgencyId
                        AND pc.ProviderId = @ProviderId
               ) t
               GROUP BY t.CreationDate, 
                        t.Type, 
                        t.Description;

        -- Payment checks fee

        INSERT INTO @result
               SELECT 10, 
                      t.Type, 
                      t.CreationDate, 
                      t.Description, 
                       NULL,
                      SUM(t.Usd) AS Usd,
					  0 - SUM(t.Usd)
                     
               FROM
               (
                   SELECT 'PAYMENT CHECKS FEE' AS Type, 
                          CAST(pc.Date AS DATE) AS CreationDate, 
                          dbo.Agencies.Code + ' - ' + dbo.Agencies.Name + ' (' + CASE
                                                                                     WHEN dbo.ProviderTypes.Code = 'C02'
                                                                                     THEN ISNULL(
                   (
                       SELECT TOP 1 mt.Number
                       FROM MoneyTransferxAgencyNumbers mt
                       WHERE mt.AgencyId = pc.AgencyId
                             AND mt.ProviderId = pc.ProviderId
                   ), 'Number not registered')
                                                                                     ELSE dbo.Providers.Name
                                                                                 END + ') ' + CAST(CONVERT(VARCHAR, pc.FromDate, 110) AS VARCHAR(10)) + ' TO ' + CAST(CONVERT(VARCHAR, pc.ToDate, 110) AS VARCHAR(10)) AS Description, 
                          Fee AS Usd
                   FROM dbo.PaymentChecks pc
                        INNER JOIN dbo.Agencies ON pc.AgencyId = dbo.Agencies.AgencyId
                        INNER JOIN dbo.Providers ON pc.ProviderId = dbo.Providers.ProviderId
                        INNER JOIN dbo.ProviderTypes ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
                   WHERE((@FromDate IS NULL)
                         OR (CAST([Date] AS DATE) >= CAST(@FromDate AS DATE)))
                        AND ((@ToDate IS NULL)
                             OR (CAST([Date] AS DATE) <= CAST(@ToDate AS DATE)))
                        AND pc.AgencyId = @AgencyId
                        AND Fee > 0
                        AND pc.ProviderId = @ProviderId
               ) t
               GROUP BY t.CreationDate, 
                        t.Type, 
                        t.Description;

        -- Commission payment - Adjustment

        INSERT INTO @result
               SELECT 11, 
                      'ADJUSTMENT' AS Type, 
                      CAST(dbo.ProviderCommissionPayments.AdjustmentDate AS DATE) AS CreationDate, 
                      'COMMISSIONS ' + UPPER(DateName(month, DATEADD(month, dbo.ProviderCommissionPayments.Month, 0) - 1)) + ' ' + CAST(dbo.ProviderCommissionPayments.Year AS VARCHAR(4)) AS Description, 
                      Usd, 
                      NULL,
					  0 + Usd
               FROM dbo.ProviderCommissionPayments
                    INNER JOIN ProviderCommissionPaymentTypes pt ON pt.ProviderCommissionPaymentTypeId = dbo.ProviderCommissionPayments.ProviderCommissionPaymentTypeId
               WHERE dbo.ProviderCommissionPayments.AgencyId = @AgencyId
                     AND dbo.ProviderCommissionPayments.ProviderId = @ProviderId
                     AND CAST(dbo.ProviderCommissionPayments.AdjustmentDate AS DATE) >= CAST(@FromDate AS DATE)
                     AND CAST(dbo.ProviderCommissionPayments.AdjustmentDate AS DATE) <= CAST(@ToDate AS DATE)
                     AND pt.Code = 'CODE04';


 -- Payment checks fee

        INSERT INTO @result
               SELECT 12, 
                      t.Type, 
                      t.CreationDate, 
                      t.Description, 
                        SUM(t.Usd) AS Usd,
                     
                       NULL,
					   0 + SUM(t.Usd)
                    
               FROM
               (
                   SELECT 'CASH (AGENCY TO AGENCY) PROVIDER' AS Type,
                          CAST(Date AS DATE) AS CreationDate, 
                        dbo.Agencies.Code  + ' TO ' +  Agencies_1.Code + ' - ' + dbo.Providers.Name +
        CASE
          WHEN dbo.ProviderTypes.Code = 'C02' THEN ' - ' + ISNULL((SELECT TOP 1
                mt.Number
              FROM MoneyTransferxAgencyNumbers mt
              WHERE mt.AgencyId = dbo.PaymentCashAgentToAgent.AgencyId
              AND mt.ProviderId = dbo.PaymentCashAgentToAgent.ProviderId)
            , 'NOT REGISTERED')
          ELSE ''
        END AS Description,
                          dbo.PaymentCashAgentToAgent.Usd AS Usd
                   FROM dbo.PaymentCashAgentToAgent 
                      INNER JOIN dbo.Agencies AS Agencies_1
        ON dbo.PaymentCashAgentToAgent.AgencyId = Agencies_1.AgencyId
      INNER JOIN dbo.Agencies
        ON dbo.PaymentCashAgentToAgent.FromAgencyId = dbo.Agencies.AgencyId
      INNER JOIN dbo.Providers
        ON dbo.Providers.ProviderId = dbo.PaymentCashAgentToAgent.ProviderId
      INNER JOIN dbo.ProviderTypes
        ON dbo.ProviderTypes.ProviderTypeId = dbo.Providers.ProviderTypeId
      WHERE CAST([Date] AS DATE) >= CAST(@FromDate AS DATE)
      AND CAST([Date] AS DATE) <= CAST(@ToDate AS DATE)
      AND dbo.PaymentCashAgentToAgent.AgencyId = @AgencyId
       AND PaymentCashAgentToAgent.ProviderId = @ProviderId
       AND dbo.PaymentCashAgentToAgent.DeletedOn IS NULL
                  
               ) t
               GROUP BY t.CreationDate, 
                        t.Type, 
                        t.Description;


 -- Cancellation

  INSERT INTO @result
         SELECT 13,
         'CANCELLATION' AS Type,
         dbo.Cancellations.CancellationDate AS CreationDate,
		 'CANCELLATION - ' + dbo.Cancellations.ReceiptCancelledNumber AS Description,
         ((TotalTransaction + Fee)*-1) AS Usd,
		 NULL,
		 0 + ((TotalTransaction + Fee)*-1)
         FROM dbo.Cancellations
              INNER JOIN
              dbo.Providers
              ON dbo.Cancellations.ProviderCancelledId = dbo.Providers.ProviderId
              INNER JOIN
              dbo.ProviderTypes
              ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
              LEFT JOIN
              dbo.CancellationTypes
              ON dbo.CancellationTypes.CancellationTypeId = dbo.Cancellations.CancellationTypeId
         WHERE AgencyId = @AgencyId AND
               ProviderCancelledId = @ProviderId AND
               CAST(dbo.Cancellations.CancellationDate AS date) >= CAST(@FromDate AS date) AND
               CAST(dbo.Cancellations.CancellationDate AS date) <= CAST(@ToDate AS date);


         RETURN;
     END;
GO