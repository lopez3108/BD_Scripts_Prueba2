SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetReportCardPaymentsCommissions]
(@AgencyId INT, 
 @FromDate DATETIME = NULL, 
 @ToDate   DATETIME = NULL, 
 @Date     DATETIME
)
AS
    BEGIN
        DECLARE 
--        @YearFrom AS INT,
--        @YearTo AS INT,
--        @MonthFrom AS INT,
--        @MonthTo AS INT,
        @ProviderId AS INT,
        @FromDateInitial AS DATETIME;
        IF(@FromDate IS NULL)
            BEGIN
                SET @FromDate = DATEADD(day, -10, @Date);
                SET @ToDate = @Date;
            END;
        SET @FromDateInitial = DATEADD(day, -1, @FromDate);
--        SET @YearFrom = CAST(YEAR(CAST(@FromDate AS DATE)) AS VARCHAR(10));
--        SET @YearTo = CAST(YEAR(CAST(@ToDate AS DATE)) AS VARCHAR(10));
--        SET @MonthFrom = CAST(MONTH(CAST(@FromDate AS DATE)) AS VARCHAR(10));
--        SET @MonthTo = CAST(MONTH(CAST(@ToDate AS DATE)) AS VARCHAR(10));
        SET @ProviderId =
        (
            SELECT TOP 1 ProviderId
            FROM Providers
                 INNER JOIN ProviderTypes ON Providers.ProviderTypeId = ProviderTypes.ProviderTypeId
            WHERE ProviderTypes.Code = 'C25'
        );
      IF OBJECT_ID('#TempTableDiscountsFinal') IS NOT NULL
            BEGIN
                DROP TABLE #TempTableDiscountsFinal;
            END;

        CREATE TABLE #TempTableDiscountsFinal
        (RowNumber     INT, 
         RowNumberDetail INT,
         AgencyId      INT, 
         Date          DATETIME, 
         Description   VARCHAR(1000), 
         Type          VARCHAR(1000), 
         Transactions  INT, 
         TypeId        INT, 
         Usd           DECIMAL(18, 2), 
         FeeService    DECIMAL(18, 2), 
         Credit        DECIMAL(18, 2), 
         BalanceDetail DECIMAL(18, 2),
            Balance DECIMAL(18, 2)
        );

        IF OBJECT_ID('#TempTableDiscounts') IS NOT NULL
            BEGIN
                DROP TABLE #TempTableDiscounts;
            END;
        CREATE TABLE #TempTableDiscounts
        (RowNumberDetail     INT, 
         AgencyId      INT, 
         Date          DATETIME, 
         Description   VARCHAR(1000), 
         Type          VARCHAR(1000), 
         Transactions  INT, 
         TypeId        INT, 
         Usd           DECIMAL(18, 2), 
         FeeService    DECIMAL(18, 2), 
         Credit        DECIMAL(18, 2), 
         BalanceDetail DECIMAL(18, 2),
              Balance DECIMAL(18, 2)
        );
        INSERT INTO #TempTableDiscounts
        (RowNumberDetail, 
         AgencyId, 
         Date, 
         Description, 
         Type, 
         Transactions, 
         TypeId, 
         Usd, 
         FeeService, 
         Credit, 
         BalanceDetail,
         Balance
        )


  SELECT 
      *
    FROM (SELECT TOP 1
        RowNumberDetail
       ,AgencyId
       ,CAST(@FromDateInitial AS Date) Date
--      ,CAST(Usd AS VARCHAR(100))
      ,'INITIAL BALANCE'  Description
       ,'INITIAL BALANCE' Type
       ,0 Transactions
       ,0 TypeId
       ,0 Usd
       ,0 FeeService
       ,0 Credit
       ,Balance BalanceDetail
       ,Balance Balance
      FROM dbo.[FN_GetComissionsCardPaymentsNew](NULL,@FromDateInitial, NULL, NULL,@AgencyId, 0)
      ORDER BY RowNumberDetail DESC
      UNION ALL

      SELECT
        *
      FROM dbo.[FN_GetComissionsCardPaymentsNew](@FromDate,@ToDate, NULL, NULL,@AgencyId, 0)
      WHERE Type != 'INITIAL BALANCE') AS Query;

  INSERT INTO #TempTableDiscountsFinal (RowNumber,
  RowNumberDetail,
  AgencyId,
  Date,
  Description,
  Type,
  Transactions,
  TypeId,
  Usd,
    FeeService,
  Credit,
  BalanceDetail,
  Balance)
    SELECT
      *
    FROM (SELECT
        ROW_NUMBER() OVER (ORDER BY CAST(Query.Date AS DATE) ASC, Query.TypeId ASC
        ) RowNumber
       ,*
      FROM (SELECT
          *
        FROM #TempTableDiscounts) AS Query) AS QueryFinal;
  SELECT
    *
   ,(SELECT
        SUM(t2.BalanceDetail)
      FROM #TempTableDiscountsFinal t2
      WHERE t2.RowNumber <= t1.RowNumber)
    BalanceFinal
  FROM #TempTableDiscountsFinal t1
  ORDER BY RowNumber ASC;
END;



GO