SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetReportMoneyOrdersCommission]
(@AgencyId   INT,
 @FromDate   DATETIME = NULL,
 @ToDate     DATETIME = NULL,
 @Date       DATETIME,
 @ProviderId INT
)
AS
     BEGIN
         DECLARE @YearFrom AS INT, @YearTo AS INT, @MonthFrom AS INT, @MonthTo AS INT;
         IF(@FromDate IS NULL)
             BEGIN
                 SET @FromDate = DATEADD(day, -10, @Date);
                 SET @ToDate = @Date;
         END;
         SET @YearFrom = CAST(YEAR(CAST(@FromDate AS DATE)) AS VARCHAR(10));
         SET @YearTo = CAST(YEAR(CAST(@ToDate AS DATE)) AS VARCHAR(10));
         SET @MonthFrom = CAST(MONTH(CAST(@FromDate AS DATE)) AS VARCHAR(10));
         SET @MonthTo = CAST(MONTH(CAST(@ToDate AS DATE)) AS VARCHAR(10));
         CREATE TABLE #TempTableMoneyOrderCommissions
         (RowNumber    INT,
          --AgencyId     INT,
          Date         DATETIME,
          Type         VARCHAR(1000),
          TypeId       INT,
          Description  VARCHAR(1000),
          Transactions VARCHAR(1000),
          Debit        DECIMAL(18, 2),
          Credit       DECIMAL(18, 2),
          Balance      DECIMAL(18, 2),
         );
         INSERT INTO #TempTableMoneyOrderCommissions
         (RowNumber,
          --AgencyId,
          Date,
          Type,
          TypeId,
          Description,
          Transactions,
          Debit,
          Credit,
          Balance
         )
                SELECT *
                FROM
                (
                    SELECT ROW_NUMBER() OVER(ORDER BY Query.Type ASC,
                                                      CAST(Query.Date AS DATE) ASC) RowNumber,
                           *
                    FROM
                    (
                        SELECT CAST(q.Date AS DATE) AS Date,
                               'CLOSING DAILY' AS Type,
                               1 TypeId,
                               'CLOSING DAILY M.O' AS Description,
                               SUM(Q.Transactions) Transactions,
                               ABS(SUM(Q.Debit)) Debit,
						       0 Credit,                               
                               ABS(SUM(Balance)) Balance
                        FROM
                        (
                            SELECT CAST(dbo.Daily.CreationDate AS DATE) AS Date,
                                   (ISNULL(dbo.MoneyTransfers.TransactionsNumberMoneyOrders, 0)) Transactions,
                                   (((ISNULL(dbo.MoneyTransfers.TransactionsNumberMoneyOrders, 0)) * (ISNULL(dbo.MoneyTransfers.MoneyOrderFee, 0))) - ((ISNULL(dbo.MoneyTransfers.TransactionsNumberMoneyOrders, 0)) * (ISNULL(dbo.MoneyTransfers.ProviderMoneyCommission, 0)))) Debit,
                                   (((ISNULL(dbo.MoneyTransfers.TransactionsNumberMoneyOrders, 0)) * (ISNULL(dbo.MoneyTransfers.MoneyOrderFee, 0))) - (SUM(ISNULL(dbo.MoneyTransfers.TransactionsNumberMoneyOrders, 0)) * (ISNULL(dbo.MoneyTransfers.ProviderMoneyCommission, 0)))) AS Balance
                            FROM dbo.Daily
                                 INNER JOIN dbo.Cashiers ON dbo.Cashiers.CashierId = dbo.Daily.CashierId
                                 INNER JOIN dbo.MoneyTransfers ON MoneyTransfers.TransactionsNumberMoneyOrders > 0
                                                                  AND dbo.Daily.AgencyId = dbo.MoneyTransfers.AgencyId
                                                                  AND CAST(dbo.MoneyTransfers.CreationDate AS DATE) = CAST(daily.CreationDate AS DATE)
                                                                  AND dbo.Cashiers.UserId = dbo.MoneyTransfers.CreatedBy

                                 INNER JOIN dbo.Providers ON dbo.MoneyTransfers.ProviderId = dbo.Providers.ProviderId
                                                             --AND dbo.Providers.MoneyOrderService = 1
                            WHERE dbo.Daily.AgencyId = @AgencyId
                                  AND CAST(dbo.Daily.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                                  AND CAST(dbo.Daily.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                                  AND dbo.MoneyTransfers.ProviderId = @ProviderId
                            GROUP BY CAST(dbo.Daily.CreationDate AS DATE),
                                     dbo.Daily.AgencyId, 
							  dbo.MoneyTransfers.TransactionsNumberMoneyOrders , 
							  dbo.MoneyTransfers.MoneyOrderFee, 
							  dbo.MoneyTransfers.ProviderMoneyCommission,
							  dbo.Daily.DailyId
                        ) Q
				     GROUP BY CAST(Q.DATE AS DATE)
                        UNION ALL
                        SELECT CAST(dbo.ProviderCommissionPayments.CreationDate AS DATE) AS DATE,
                               'PAYMENT' AS Type,
                               2 TypeId,
                               'COMMISSION PAYMENT' AS Description,
                               '-' Transactions,
                               0 Debit,
                               ABS(ISNULL(SUM(ProviderCommissionPayments.UsdMoneyOrders), 0)) Credit,
                               -ISNULL(ABS(SUM(ProviderCommissionPayments.UsdMoneyOrders)), 0) BalanceDetail
                        FROM dbo.ProviderCommissionPayments
                             INNER JOIN dbo.Providers ON dbo.ProviderCommissionPayments.ProviderId = dbo.Providers.ProviderId
                             INNER JOIN dbo.ProviderCommissionPaymentTypes ON dbo.ProviderCommissionPayments.ProviderCommissionPaymentTypeId = dbo.ProviderCommissionPaymentTypes.ProviderCommissionPaymentTypeId
                             INNER JOIN dbo.Agencies ON dbo.ProviderCommissionPayments.AgencyId = dbo.Agencies.AgencyId
                             LEFT OUTER JOIN dbo.Bank ON dbo.ProviderCommissionPayments.BankId = dbo.Bank.BankId
                             INNER JOIN dbo.ProviderTypes ON dbo.ProviderTypes.ProviderTypeId = dbo.Providers.ProviderTypeId
                        WHERE ProviderCommissionPayments.AgencyId = @AgencyId
                              AND (((ProviderCommissionPayments.Year = @YearFrom
                                     AND (ProviderCommissionPayments.Month >= @MonthFrom))
                                    OR (ProviderCommissionPayments.Year > @YearFrom))
                                   AND ((ProviderCommissionPayments.Year = @YearTo
                                         AND (ProviderCommissionPayments.Month <= @MonthTo))
                                        OR (ProviderCommissionPayments.Year < @YearTo)))
                              AND ProviderCommissionPayments.ProviderId = @ProviderId
                        GROUP BY CAST(dbo.ProviderCommissionPayments.CreationDate AS DATE)
                    ) AS Query
                ) AS QueryFinal;
         SELECT *,
         (
             SELECT SUM(t2.Balance)
             FROM #TempTableMoneyOrderCommissions t2
             WHERE T2.RowNumber <= T1.RowNumber
         ) BalanceFinal
         FROM #TempTableMoneyOrderCommissions t1
         ORDER BY RowNumber ASC;
     END;
GO