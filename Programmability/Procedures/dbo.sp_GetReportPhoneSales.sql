SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetReportPhoneSales]
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
             WHERE ProviderTypes.Code = 'C12'
         );
         IF OBJECT_ID('#TempTablePhone') IS NOT NULL
             BEGIN
                 DROP TABLE #TempTablePhone;
         END;
         CREATE TABLE #TempTablePhoneFinal
         (RowNumber       INT,
          RowNumberDetail INT,
          AgencyId        INT,
          Date            DATETIME,
          Description     VARCHAR(1000),
          Type            VARCHAR(1000),
          TypeId          INT,
          Usd             DECIMAL(18, 2),
          Cost            DECIMAL(18, 2),
          Credit          DECIMAL(18, 2),
          BalanceDetail   DECIMAL(18, 2),         
		  UnidadesVendidas INT,
		  Tax             DECIMAL(18, 2),
		   Balance         DECIMAL(18, 2)
         );
         CREATE TABLE #TempTablePhone
         (RowNumberDetail INT,
          AgencyId        INT,
          Date            DATETIME,
          Description     VARCHAR(1000),
          Type            VARCHAR(1000),
          TypeId          INT,
          Usd             DECIMAL(18, 2),
          Cost            DECIMAL(18, 2),
          Credit          DECIMAL(18, 2),
          BalanceDetail   DECIMAL(18, 2),         
		  UnidadesVendidas INT,
		  Tax             DECIMAL(18, 2),
		   Balance         DECIMAL(18, 2)
         );
         INSERT INTO #TempTablePhone
         (RowNumberDetail,
          AgencyId,
          Date,
          Description,
          Type,
          TypeId,
          Usd,
          Cost,
          Credit,
          BalanceDetail,     
		  UnidadesVendidas,
		  Tax,
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
                                 0 Cost,
                                 0 Credit,
                                 Balance BalanceDetail,                                
								 0 AS UnidadesVendidas,
								 0 AS Tax ,
								 Balance

                    FROM dbo.FN_GenerateBalancePhoneSales(@AgencyId, NULL, @FromDateInitial, @ProviderId, NULL, NULL, @YearFrom, @MonthFrom, 1)
                    ORDER BY RowNumberDetail DESC
                    UNION ALL
                    SELECT *
                    FROM dbo.FN_GenerateBalancePhoneSales(@AgencyId, @FromDate, @ToDate, @ProviderId, @YearFrom, @MonthFrom, @YearTo, @MonthTo, 2)
                ) AS Query;
         INSERT INTO #TempTablePhoneFinal
         (RowNumber,
          RowNumberDetail,
          AgencyId,
          Date,
          Description,
          Type,
          TypeId,
          Usd,
          Cost,
          Credit,
          BalanceDetail,    
		  UnidadesVendidas,
		  Tax,
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
                        FROM #TempTablePhone
                    ) AS Query
                ) AS QueryFinal;
         SELECT *,
         (
             SELECT SUM(t2.BalanceDetail)
             FROM #TempTablePhoneFinal t2
             WHERE T2.RowNumber <= T1.RowNumber
         ) BalanceFinal
         FROM #TempTablePhoneFinal t1
         ORDER BY RowNumber ASC;
     END;
GO