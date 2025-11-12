SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetReportNotary]
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
             WHERE ProviderTypes.Code = 'C15'
         );
         IF OBJECT_ID('#TempTableNotaryFinal') IS NOT NULL
             BEGIN
                 DROP TABLE #TempTableNotaryFinal;
         END;
         CREATE TABLE #TempTableNotaryFinal
         (RowNumber       INT,
          RowNumberDetail INT,
          AgencyId        INT,
          Date            DATETIME,
          Description     VARCHAR(1000),
          Type            VARCHAR(1000),
          TypeId          INT,
          Usd             DECIMAL(18, 2),
          Credit          DECIMAL(18, 2),
          BalanceDetail   DECIMAL(18, 2),
          Balance         DECIMAL(18, 2)
         );
         IF OBJECT_ID('#TempTableNotary') IS NOT NULL
             BEGIN
                 DROP TABLE #TempTableNotary;
         END;
         CREATE TABLE #TempTableNotary
         (RowNumberDetail INT,
          AgencyId        INT,
          Date            DATETIME,
          Description     VARCHAR(1000),
          Type            VARCHAR(1000),
          TypeId          INT,
          Usd             DECIMAL(18, 2),
          Credit          DECIMAL(18, 2),
          BalanceDetail   DECIMAL(18, 2),
          Balance         DECIMAL(18, 2)
         );
         INSERT INTO #TempTableNotary
         (RowNumberDetail,
          AgencyId,
          Date,
          Description,
          Type,
          TypeId,
          Usd,
          Credit,
          BalanceDetail,
          Balance
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
                                 0 Usd,
                                 0 Credit,
                                 Balance BalanceDetail,
                                 Balance
                    FROM dbo.FN_GenerateBalanceNotary(@AgencyId, NULL, @FromDateInitial, @ProviderId, NULL, NULL, @YearFrom, @MonthFrom, 1) AS a
                    ORDER BY a.RowNumberDetail DESC
                    UNION ALL
                    SELECT *
                    FROM dbo.FN_GenerateBalanceNotary(@AgencyId, @FromDate, @ToDate, @ProviderId, @YearFrom, @MonthFrom, @YearTo, @MonthTo, 2)
                ) AS Query;
         INSERT INTO #TempTableNotaryFinal
         (RowNumber,
          RowNumberDetail,
          AgencyId,
          Date,
          Description,
          Type,
          TypeId,
          Usd,
          Credit,
          BalanceDetail,
          Balance
         )
                SELECT *
                FROM
                (
                    SELECT ROW_NUMBER() OVER(ORDER BY Query.TypeId ASC,
                                                      CAST(Query.Date AS DATE) ASC) RowNumber,
                           *
                    FROM
                    (
                        SELECT *
                        FROM #TempTableNotary
                    ) AS Query
                ) AS QueryFinal;
         SELECT *,
         (
             SELECT SUM(t2.BalanceDetail)
             FROM #TempTableNotaryFinal t2
             WHERE T2.RowNumber <= T1.RowNumber
         ) BalanceFinal
         FROM #TempTableNotaryFinal t1



         ORDER BY RowNumber ASC;
     END;
GO