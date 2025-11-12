SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetReportMoneyOrders]
(@AgencyId   INT,
 @FromDate   DATETIME = NULL,
 @ToDate     DATETIME = NULL,
 @Date       DATETIME,
 @ProviderId INT
)
AS
     BEGIN
         IF(@FromDate IS NULL)
             BEGIN
                 SET @FromDate = DATEADD(day, -10, @Date);
                 SET @ToDate = @Date;
         END;
         CREATE TABLE #TempTableMoneyOrder
         (RowNumber    INT,
          --AgencyId     INT,
          Date         DATETIME,
          Type         VARCHAR(1000),
          Description  VARCHAR(1000),
          Usd          DECIMAL(18, 2),
          Transactions INT
         );
         INSERT INTO #TempTableMoneyOrder
         (RowNumber,
          --AgencyId,
          Date,
          Type,
          Description,
          Transactions,
          Usd
         )
                SELECT *
                FROM
                (
                    SELECT ROW_NUMBER() OVER(ORDER BY Query.Type ASC,
                                                      CAST(Query.Date AS DATE) ASC) RowNumber,
                           *
                    FROM
                    (
                        SELECT CAST(dbo.Daily.CreationDate AS DATE) AS Date,
                               'CLOSING DAILY' AS Type,
                               'CLOSING DAILY M.O' AS Description,
                               SUM(ISNULL(dbo.MoneyTransfers.TransactionsNumberMoneyOrders, 0)) Transactions,
                               
						 SUM(ISNULL(dbo.MoneyTransfers.UsdMoneyOrders, 0)) AS Usd
                        FROM dbo.Daily
                             INNER JOIN dbo.Cashiers ON dbo.Cashiers.CashierId = dbo.Daily.CashierId
                             INNER JOIN dbo.MoneyTransfers ON MoneyTransfers.TransactionsNumberMoneyOrders > 0 and dbo.Daily.AgencyId = dbo.MoneyTransfers.AgencyId
                                                              AND CAST(dbo.MoneyTransfers.CreationDate AS DATE) = CAST(daily.CreationDate AS DATE)
                                                              AND dbo.Cashiers.UserId = dbo.MoneyTransfers.CreatedBy
                             INNER JOIN dbo.Providers ON dbo.MoneyTransfers.ProviderId = dbo.Providers.ProviderId
                                                         --AND dbo.Providers.MoneyOrderService = 1 4600 se comento porque independientemente si el providers esta inactivo se debe de mostrar la operacion con este provider.
                        WHERE dbo.Daily.AgencyId = @AgencyId
                              AND CAST(dbo.Daily.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                              AND CAST(dbo.Daily.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                              AND dbo.MoneyTransfers.ProviderId = @ProviderId
                        GROUP BY  CAST(dbo.Daily.CreationDate AS DATE)
                    ) AS Query
                ) AS QueryFinal;
         SELECT *,
         (
             SELECT SUM(t2.Usd)
             FROM #TempTableMoneyOrder t2
             WHERE T2.RowNumber <= T1.RowNumber
         ) BalanceFinal
         FROM #TempTableMoneyOrder t1
         ORDER BY RowNumber ASC;
       
     END;
GO