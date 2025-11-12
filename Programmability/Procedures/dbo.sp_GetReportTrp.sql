SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- UpdateBy Felipe oquendo task 5372

CREATE PROCEDURE [dbo].[sp_GetReportTrp]
(@AgencyId INT,
 @FromDate DATETIME = NULL,
 @ToDate   DATETIME = NULL,
 @Date     DATETIME
)
AS
     BEGIN
         DECLARE @YearFrom AS INT, @YearTo AS INT, @MonthFrom AS INT, @MonthTo AS INT, @ProviderId AS INT, @FromDateInitial AS DATETIME;
         IF(@FromDate IS NULL)
             BEGIN
                 SET @FromDate = DATEADD(day, -10, @Date);
                 SET @ToDate = @Date;
         END;
         SET @FromDateInitial = DATEADD(day, -1, @FromDate);
         SET @YearFrom = CAST(YEAR(CAST(@FromDate AS DATE)) AS VARCHAR(10));
         SET @YearTo = CAST(YEAR(CAST(@ToDate AS DATE)) AS VARCHAR(10));
         SET @MonthFrom = CAST(MONTH(CAST(@FromDate AS DATE)) AS VARCHAR(10));
         SET @MonthTo = CAST(MONTH(CAST(@ToDate AS DATE)) AS VARCHAR(10));
         SET @ProviderId =
         (
             SELECT TOP 1 ProviderId
             FROM Providers
                  INNER JOIN ProviderTypes ON Providers.ProviderTypeId = ProviderTypes.ProviderTypeId
             WHERE ProviderTypes.Code = 'C09'
         );
         IF OBJECT_ID('#TempTableTrpFinal') IS NOT NULL
             BEGIN
                 DROP TABLE #TempTableTrpFinal;
         END;
         CREATE TABLE #TempTableTrpFinal
         (RowNumber       INT,
          RowNumberDetail INT,
          AgencyId        INT,
          Date            DATETIME,
          Description     VARCHAR(1000),
          Type            VARCHAR(1000),
          TypeId          INT,
          Transactions    INT,
          Usd             DECIMAL(18, 2),
          FeeService      DECIMAL(18, 2),
          TrpFee          DECIMAL(18, 2),
          TrpCreditCost   DECIMAL(18, 2),
          Credit          DECIMAL(18, 2),
          BalanceCostDetail DECIMAL(18, 2),
          BalanceCommissionDetail   DECIMAL(18, 2),
          BalanceCost DECIMAL(18, 2),
          BalanceCommission         DECIMAL(18, 2)
         );
         IF OBJECT_ID('#TempTableTrp') IS NOT NULL
             BEGIN
                 DROP TABLE #TempTableTrp;
         END;
         CREATE TABLE #TempTableTrp
         (RowNumberDetail INT,
          AgencyId        INT,
          Date            DATETIME,
          Description     VARCHAR(1000),
          Type            VARCHAR(1000),
          TypeId          INT,
          Transactions    INT,
          Usd             DECIMAL(18, 2),
          FeeService      DECIMAL(18, 2),
          TrpFee          DECIMAL(18, 2),          
          TrpCreditCost   DECIMAL(18, 2),
          Credit          DECIMAL(18, 2),
          BalanceCostDetail DECIMAL(18, 2),
          BalanceCommissionDetail   DECIMAL(18, 2),
          BalanceCost     DECIMAL(18, 2),
          BalanceCommission         DECIMAL(18, 2)
         );
         INSERT INTO #TempTableTrp
         (RowNumberDetail,
          AgencyId,
          Date,
          Description,
          Type,
          TypeId,
          Transactions,
          Usd,
          FeeService,        
          TrpFee,
          TrpCreditCost,
          Credit,
          BalanceCostDetail,
          BalanceCommissionDetail,
          BalanceCost,
          BalanceCommission
         )
                SELECT *
                FROM
                (
                    SELECT TOP 1 RowNumberDetail,
                                 AgencyId,
                                 CAST(@FromDateInitial AS DATE) Date,
                                 'INITIAL BALANCE' Description,
                                 'INITIAL BALANCE' Type,
                                 0 TypeId,
                                 0 Transactions,
                                 0 Usd,
                                 0 FeeService,
                                 0 TrpFee,
                                 0 TrpCreditCost,
                                 0 Credit,
                                 BalanceCost BalanceCostDetail,
                                 BalanceCommission BalanceCommissionDetail,
                                 BalanceCost,
                                 BalanceCommission
                    FROM dbo.FN_GenerateBalanceTrp(@AgencyId, NULL, @FromDateInitial, @ProviderId, NULL, NULL, @YearFrom, @MonthFrom, 1)
                    ORDER BY RowNumberDetail DESC
                    UNION ALL
                    SELECT *
                    FROM dbo.FN_GenerateBalanceTrp(@AgencyId, @FromDate, @ToDate, @ProviderId, @YearFrom, @MonthFrom, @YearTo, @MonthTo, 2)
                ) AS Query;
         INSERT INTO #TempTableTrpFinal
         (RowNumber,
          RowNumberDetail,
          AgencyId,
          Date,
          Description,
          Type,
          TypeId,
          Transactions,
          Usd,
          FeeService,
          TrpFee,
          TrpCreditCost,
          Credit,
          BalanceCostDetail,
          BalanceCommissionDetail,
          BalanceCost,
          BalanceCommission
         )
                SELECT *
                FROM
                (
                -- UpdateBy Felipe oquendo task 5372  ordenar por Date
                    SELECT ROW_NUMBER() OVER(ORDER BY CAST(Query.Date AS DATE) ASC, Query.TypeId  ASC) RowNumber,
                           *
                    FROM
                    (
                        SELECT *
                        FROM #TempTableTrp
                    ) AS Query
                ) AS QueryFinal;
         SELECT *,
         (
             SELECT SUM(CAST(t2.BalanceCostDetail AS DECIMAL(18,2)))
             FROM #TempTableTrpFinal t2
             WHERE T2.RowNumber <= T1.RowNumber
         ) BalanceCostFinal,
         (
             SELECT SUM(CAST(t2.BalanceCommissionDetail AS DECIMAL(18,2)))
             FROM #TempTableTrpFinal t2
             WHERE T2.RowNumber <= T1.RowNumber
         ) BalanceCommissionFinal
         FROM #TempTableTrpFinal t1
         ORDER BY RowNumber ASC;
     END;




GO