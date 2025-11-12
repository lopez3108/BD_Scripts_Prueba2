SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:21-09-2023
--CAMBIOS EN 5389,Refactorizacion de reporte vehicle service
CREATE PROCEDURE [dbo].[sp_GetReportElsCommissionsElCorp]
(@AgencyId INT,
 @FromDate DATETIME = NULL,
 @ToDate   DATETIME = NULL,
 @Date     DATETIME
)
AS
BEGIN
  DECLARE  @FromDateInitial AS DATETIME;
         IF(@FromDate IS NULL)
             BEGIN
                 SET @FromDate = DATEADD(day, -10, @Date);
                 SET @ToDate = @Date;
         END;
        SET @FromDateInitial = DATEADD(day, -1, @FromDate);
  
  DECLARE @BalanceDetail DECIMAL(18,2);
  SET @BalanceDetail =   ISNULL((SELECT SUM(CAST(BalanceDetail AS DECIMAL(18,2))) FROM dbo.[FN_GenerateBalanceElsCommissionsElCorp](@AgencyId, '1985-01-01', @FromDateInitial)),0)

  CREATE TABLE #Temp 
  (
           [ID] INT IDENTITY(1,1),
           [Index]        INT, 
          AgencyId         INT,
          Date             DATETIME,
          Description      VARCHAR(1000),
          Type             VARCHAR(1000),
          TypeId           INT,
          TypeDetailId     INT,
          Transactions     INT,
          CommissionElCorp DECIMAL(18, 2),
          Credit           DECIMAL(18, 2),
          BalanceDetail    DECIMAL(18, 2)
--          Balance          DECIMAL(18, 2)
  )


  		INSERT INTO #Temp

SELECT  1 [Index],
                                           @AgencyId AgencyId,
                                           CAST(@FromDateInitial AS DATE) Date,
                                           'INITIAL BALANCE' Description,
                                           'INITIAL BALANCE' Type,
                                           0 TypeId,
                                           0 TypeDetailId,
                                           0 Transactions,
                                           0 CommissionElCorp,
                                           0 Credit,
                                           @BalanceDetail BalanceDetail
                                           UNION ALL

       SELECT *
                   FROM dbo.[FN_GenerateBalanceElsCommissionsElCorp](@AgencyId, @FromDate, @ToDate)
          ORDER BY Date, 
                   [Index];
		
  				SELECT 
  				 *,
  				 (
              SELECT ISNULL( SUM(CAST(BalanceDetail AS DECIMAL(18,2))), 0)
              FROM    #Temp T2
              WHERE T2.ID <= T1.ID
          ) BalanceFinal
  				 FROM #Temp T1
  
  				 DROP TABLE #Temp
END



--     BEGIN
--         DECLARE @YearFrom AS INT, @YearTo AS INT, @MonthFrom AS INT, @MonthTo AS INT, @ProviderId AS INT, @FromDateInitial AS DATETIME;
--         IF(@FromDate IS NULL)
--             BEGIN
--                 SET @FromDate = DATEADD(day, -10, @Date);
--                 SET @ToDate = @Date;
--         END;
--         SET @FromDateInitial = DATEADD(day, -1, @FromDate);
--         SET @YearFrom = CAST(YEAR(CAST(@FromDate AS DATE)) AS VARCHAR(10));
--         SET @YearTo = CAST(YEAR(CAST(@ToDate AS DATE)) AS VARCHAR(10));
--         SET @MonthFrom = CAST(MONTH(CAST(@FromDate AS DATE)) AS VARCHAR(10));
--         SET @MonthTo = CAST(MONTH(CAST(@ToDate AS DATE)) AS VARCHAR(10));
--         SET @ProviderId =
--         (
--             SELECT TOP 1 ProviderId
--             FROM Providers
--                  INNER JOIN ProviderTypes ON Providers.ProviderTypeId = ProviderTypes.ProviderTypeId
--             WHERE ProviderTypes.Code = 'C05'
--         );
--         IF OBJECT_ID('#TempTableElsCommissionsElCorpFinal') IS NOT NULL
--             BEGIN
--                 DROP TABLE #TempTableElsCommissionsElCorpFinal;
--         END;
--         CREATE TABLE #TempTableElsCommissionsElCorpFinal
--         (RowNumber        INT,
--          RowNumberDetail  INT,
--          AgencyId         INT,
--          Date             DATETIME,
--          Description      VARCHAR(1000),
--          Type             VARCHAR(1000),
--          TypeId           INT,
--          TypeDetailId     INT,
--          Transactions     INT,
--          CommissionElCorp DECIMAL(18, 2),
--          Credit           DECIMAL(18, 2),
--          BalanceDetail    DECIMAL(18, 2),
--          Balance          DECIMAL(18, 2)
--         );
--         IF OBJECT_ID('#TempTableElsCommissionsElCorp') IS NOT NULL
--             BEGIN
--                 DROP TABLE #TempTableElsCommissionsElCorp;
--         END;
--         CREATE TABLE #TempTableElsCommissionsElCorp
--         (RowNumberDetail  INT,
--          AgencyId         INT,
--          Date             DATETIME,
--          Description      VARCHAR(1000),
--          Type             VARCHAR(1000),
--          TypeId           INT,
--          TypeDetailId     INT,
--          Transactions     INT,
--          CommissionElCorp DECIMAL(18, 2),
--          Credit           DECIMAL(18, 2),
--          BalanceDetail    DECIMAL(18, 2),
--          Balance          DECIMAL(18, 2)
--         );
--         INSERT INTO #TempTableElsCommissionsElCorp
--         (RowNumberDetail,
--          AgencyId,
--          Date,
--          Description,
--          Type,
--          TypeId,
--          TypeDetailId,
--          Transactions,
--          CommissionElCorp,
--          Credit,
--          BalanceDetail,
--          Balance
--         )
--                SELECT *
--                FROM
--                (
--                    --SELECT TOP 1 RowNumberDetail,
--                    --             AgencyId,
--                    --             CAST(@FromDateInitial AS DATE) Date,
--                    --             'INITIAL BALANCE' Description,
--                    --             'INITIAL BALANCE' Type,
--                    --             0 TypeId,
--                    --             0 Usd,
--                    --             0 FeeService,
--                    --             0 TrpFee,
--                    --             0 Credit,
--                    --             Balance BalanceDetail,
--                    --             Balance
--                    --FROM dbo.FN_GenerateBalanceTrp(@AgencyId, NULL, @FromDateInitial, @ProviderId, NULL, NULL, @YearFrom, @MonthFrom, 1)
--                    --ORDER BY RowNumberDetail DESC
--                    --UNION ALL
--
--                    SELECT *
--                    FROM dbo.[FN_GenerateBalanceElsCommissionsElCorp](@AgencyId, @FromDate, @ToDate, @ProviderId, @YearFrom, @MonthFrom, @YearTo, @MonthTo)
--                ) AS Query;
--         INSERT INTO #TempTableElsCommissionsElCorpFinal
--         (RowNumber,
--          RowNumberDetail,
--          AgencyId,
--         Date,
--          Description,
--          Type,
--          TypeId,
--          TypeDetailId,
--          Transactions,
--          CommissionElCorp,
--          Credit,
--          BalanceDetail,
--          Balance
--         )
--                SELECT *
--                FROM
--                (
--                    SELECT ROW_NUMBER() OVER(ORDER BY CAST(Query.Date AS DATE) ASC,
--					Query.TypeId ASC
--                                                      ) RowNumber,
--                           *
--                    FROM
--                    (
--                        SELECT *
--                        FROM #TempTableElsCommissionsElCorp
--                    ) AS Query
--                ) AS QueryFinal;
--         SELECT *,
--         (
--             SELECT SUM(t2.BalanceDetail)
--             FROM #TempTableElsCommissionsElCorpFinal t2
--             WHERE T2.RowNumber <= T1.RowNumber
--         ) BalanceFinal
--         FROM #TempTableElsCommissionsElCorpFinal t1
--         ORDER BY RowNumber ASC;
--     END;


GO