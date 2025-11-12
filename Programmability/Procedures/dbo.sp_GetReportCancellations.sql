SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:25-09-2023
--CAMBIOS EN 5400,Refactorizacion de reporte cancellation
CREATE PROCEDURE [dbo].[sp_GetReportCancellations] (@AgencyId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL,
@Date DATETIME)
AS
BEGIN
  IF (@FromDate IS NULL)
  BEGIN
    SET @FromDate = DATEADD(DAY, -10, @Date);
    SET @ToDate = @Date;
  END;
  DECLARE @initialBalanceFinalDate DATETIME
  SET @initialBalanceFinalDate = DATEADD(DAY, -1, @FromDate)

  DECLARE @SumDetail DECIMAL(18, 2)
  SET @SumDetail = ISNULL((SELECT
      SUM(CAST(SumDetail AS DECIMAL(18, 2)))
    FROM dbo.FN_GenerateCancellationReport(@AgencyId, '1985-01-01', @initialBalanceFinalDate))
  , 0)

  CREATE TABLE #Temp (
    [ID] INT IDENTITY (1, 1)
   ,[Index] INT
   ,Date DATETIME
   ,CancellationId INT
   ,Type VARCHAR(1000)
   ,TypeId INT
   ,Provider VARCHAR(1000)
   ,ProviderId INT
   ,Receipt VARCHAR(1000)
   ,ClientName VARCHAR(1000)
   ,TransferAmount DECIMAL(18, 2)
   ,TransferFees DECIMAL(18, 2)
   ,Credit DECIMAL(18, 2)
   ,SumDetail DECIMAL(18, 2)
   ,[Month] INT NULL
   ,[Year] INT NULL


  )


  INSERT INTO #Temp

    SELECT
      0 [Index]
     ,CAST(@initialBalanceFinalDate AS DATE) Date
     ,0 CancellationId
     ,'INITIAL BALANCE' Type
     ,1 TypeId
     ,'-' Provider
     ,0 ProviderId
     ,'-' Receipt
     ,'-' ClientName
     ,0 TransferAmount
     ,0 TransferFees
     ,0 Credit
     ,@SumDetail SumDetail
     ,NULL Month
     ,NULL Year


    UNION ALL

    SELECT
      *
    FROM [dbo].FN_GenerateCancellationReport(@AgencyId, @FromDate, @ToDate)
    ORDER BY Date,CancellationId,
    TypeId;



  SELECT
    *
   ,(SELECT
        ISNULL(SUM(CAST(SumDetail AS DECIMAL(18, 2))), 0)
      FROM #Temp T2
      WHERE T2.ID <= T1.ID)
    Balance
  FROM #Temp T1

  DROP TABLE #Temp


END





--
--     BEGIN
--         DECLARE @YearFrom AS INT, @YearTo AS INT, @MonthFrom AS INT, @MonthTo AS INT, @ProviderId AS INT;
--         IF(@FromDate IS NULL)
--             BEGIN
--                 SET @FromDate = DATEADD(day, -10, @Date);
--                 SET @ToDate = @Date;
--         END;
--         SET @YearFrom = CAST(YEAR(CAST(@FromDate AS DATE)) AS VARCHAR(10));
--         SET @YearTo = CAST(YEAR(CAST(@ToDate AS DATE)) AS VARCHAR(10));
--         SET @MonthFrom = CAST(MONTH(CAST(@FromDate AS DATE)) AS VARCHAR(10));
--         SET @MonthTo = CAST(MONTH(CAST(@ToDate AS DATE)) AS VARCHAR(10));
--         SET @ProviderId =
--         (
--             SELECT TOP 1 ProviderId
--             FROM Providers
--                  INNER JOIN ProviderTypes ON Providers.ProviderTypeId = ProviderTypes.ProviderTypeId
--             WHERE ProviderTypes.Code = 'C06'
--                   AND Providers.Active = 1
--         );
--         IF OBJECT_ID('#TempTableCancel') IS NOT NULL
--             BEGIN
--                 DROP TABLE #TempTableCancel;
--         END;
--         CREATE TABLE #TempTableCancel
--         (RowNumber      INT,
--          Date           DATETIME,
--          CancellationId INT,
--          Type           VARCHAR(1000),
--          TypeId         INT,
--          Provider       VARCHAR(1000),
--          ProviderId     INT,
--          Receipt        VARCHAR(1000),
--          ClientName     VARCHAR(1000),
--          TransferAmount DECIMAL(18, 2),
--          TransferFees   DECIMAL(18, 2),
--          Credit         DECIMAL(18, 2),
--          SumDetail      DECIMAL(18, 2)
--         );
--         INSERT INTO #TempTableCancel
--         (RowNumber,
--          Date,
--          CancellationId,
--          Type,
--          TypeId,
--          Provider,
--          ProviderId,
--          Receipt,
--          ClientName,
--          TransferAmount,
--          TransferFees,
--          Credit,
--          SumDetail
--         )
--                SELECT *
--                FROM
--                (
--                    SELECT ROW_NUMBER() OVER(ORDER BY CAST(Query.Date AS DATE) ASC,
--                                                      Query.CancellationId ASC,
--                                                      Query.Type ASC,
--                                                      Query.ClientName ASC) RowNumber,
--                           *
--                    FROM
--                    (  
--					--SELECT 
--					--   CAST(@FromDate AS DATE) AS Date,
--					--   0 CancellationId,
--					--   'INITIAL BALANCE' AS Type, 
--					--   1 TypeId,
--					--   ' - ' Provider,
--					--   0 ProviderId,
--					--   0 Receipt,
--					--  ' - ' ClientName,
--					--   0 TransferAmount,
--     --                 0TransferFees,
--     --                 0 Credit,
--     --                  dbo.fn_CalculateCancellationInitialBalance(@AgencyId, @FromDate) SumDetail
--                             
--                      -- UNION ALL
--						SELECT CAST(c.CancellationDate AS DATE) Date,
--                               c.CancellationId,
--                               'CANCELED' Type,
--                               1 TypeId,
--                               CASE
--                                   WHEN ct.Code = 'C01'
--                                   THEN p.Name+' (M.T)'
--                                   WHEN ct.Code = 'C02'
--                                   THEN p.Name+' (M.O)'
--								   ELSE
--								   p.Name
--                               END Provider,
--                               p.ProviderId,
--                               c.ReceiptCancelledNumber Receipt,
--                               c.ClientName,
--                               ABS(SUM(c.TotalTransaction)) TransferAmount,
--                               ABS(SUM(c.Fee)) TransferFees,
--                               0 Credit,
--                               (SUM(ABS(c.TotalTransaction)) + SUM(ABS(c.Fee))) SumDetail
--                        FROM Cancellations c
--                             INNER JOIN Providers p ON p.ProviderId = c.ProviderCancelledId
--                             LEFT JOIN CancellationTypes ct ON CT.CancellationTypeId = c.CancellationTypeId
--                        WHERE c.AgencyId = @AgencyId
--                              AND CAST(c.CancellationDate AS DATE) >= CAST(@FromDate AS DATE)
--                              AND CAST(c.CancellationDate AS DATE) <= CAST(@ToDate AS DATE)
--                              AND (RefundDate IS NOT NULL
--                                   OR NewTransactionDate IS NOT NULL)
--                        GROUP BY CAST(c.CancellationDate AS DATE),
--                                 p.ProviderId,
--                                 p.Name,
--                                 ct.Code,
--                                 c.ReceiptCancelledNumber,
--                                 c.ClientName,
--                                 c.CancellationId,
--                                 c.CancellationDate
--                        UNION ALL
--                        SELECT CAST(c.CancellationDate AS DATE) Date,
--                               c.CancellationId,
--                               CASE
--                                   WHEN CAST(c.RefundDate AS DATE) IS NOT NULL
--                                        AND RefundFee = 1
--                                   THEN 'REFUND (FEE)'
--                                   WHEN CAST(c.RefundDate AS DATE) IS NOT NULL
--                                        AND (RefundFee IS NULL
--                                             OR RefundFee = 0)
--
--                                   --WHEN CAST(c.RefundDate AS DATE) IS NOT NULL
--                                   THEN 'REFUND'
--                                   WHEN CAST(c.NewTransactionDate AS DATE) IS NOT NULL
--                                   THEN 'NEW TRASACCION'
--                               END AS Type,
--                               2 TypeId,
--                               CASE
--                                   WHEN CAST(c.RefundDate AS DATE) IS NOT NULL
--                                   THEN '-'
--                                   WHEN CAST(c.NewTransactionDate AS DATE) IS NOT NULL
--                                        AND ct.Code = 'C01'
--                                   THEN pnt.Name+'(M.T)'
--                                   WHEN CAST(c.NewTransactionDate AS DATE) IS NOT NULL
--                                        AND ct.Code = 'C02'
--                                   THEN pnt.Name+' (M.O)'
--								   ELSE
--								   pnt.Name
--                               END AS Provider,
--                               CASE
--                                   WHEN CAST(c.RefundDate AS DATE) IS NOT NULL
--                                   THEN ISNULL(p.ProviderId, 0)
--                                   WHEN CAST(c.NewTransactionDate AS DATE) IS NOT NULL
--                                   THEN ISNULL(pnt.ProviderId, 0)
--                               END AS ProviderId,
--                               CASE
--                                   WHEN CAST(c.RefundDate AS DATE) IS NOT NULL
--                                   THEN c.ReceiptCancelledNumber
--                                   WHEN CAST(c.NewTransactionDate AS DATE) IS NOT NULL
--                                   THEN c.ReceiptNewNumber
--                               END AS Receipt,
--                               c.ClientName,
--                               0 TransferAmount,
--                               0 TransferFees,
--                               CASE
--                                   WHEN CAST(c.RefundDate AS DATE) IS NOT NULL
--                                        AND RefundFee = 1
--                                   THEN(SUM(ABS(c.RefundAmount)) + SUM(ABS(c.Fee)))
--                                   WHEN CAST(c.RefundDate AS DATE) IS NOT NULL
--                                        AND (RefundFee IS NULL
--                                             OR RefundFee = 0)
--                                   THEN SUM(ABS(c.RefundAmount))
--                                   WHEN CAST(c.NewTransactionDate AS DATE) IS NOT NULL
--                                   THEN(SUM(ABS(c.TotalTransaction)) + SUM(ABS(c.Fee)))
--                               END AS Credit,
--                               CASE
--                                   WHEN CAST(c.RefundDate AS DATE) IS NOT NULL
--                                        AND RefundFee = 1
--                                   THEN-(SUM(ABS(c.RefundAmount)) + SUM(ABS(c.Fee)))
--                                   WHEN CAST(c.RefundDate AS DATE) IS NOT NULL
--                                        AND (RefundFee IS NULL
--                                             OR RefundFee = 0)
--                                   THEN-SUM(ABS(c.RefundAmount))
--                                   WHEN CAST(c.NewTransactionDate AS DATE) IS NOT NULL
--                                   THEN-(SUM(ABS(c.TotalTransaction)) + SUM(ABS(c.Fee)))
--                               END AS SumDetail
--                        FROM Cancellations c
--                             INNER JOIN Providers p ON p.ProviderId = c.ProviderCancelledId
--                             LEFT JOIN Providers pnt ON pnt.ProviderId = c.ProviderNewId
--                             LEFT JOIN CancellationTypes ct ON CT.CancellationTypeId = c.CancellationTypeId
--                        WHERE c.AgencyId = @AgencyId
--                              AND ((CAST(c.RefundDate AS DATE) >= CAST(@FromDate AS DATE)
--                                    AND CAST(c.RefundDate AS DATE) <= CAST(@ToDate AS DATE))
--                                   OR (CAST(c.NewTransactionDate AS DATE) >= CAST(@FromDate AS DATE)
--                                       AND CAST(c.NewTransactionDate AS DATE) <= CAST(@ToDate AS DATE)))
--                              --AND (RefundDate IS NOT NULL
--                              --     OR NewTransactionDate IS NOT NULL)
--                        GROUP BY CAST(c.CancellationDate AS DATE),
--                                 p.ProviderId,
--                                 p.Name,
--                                 ct.Code,
--                                 c.ReceiptCancelledNumber,
--                                 c.ClientName,
--                                 c.CancellationId,
--                                 c.CancellationDate,
--                                 CAST(c.RefundDate AS DATE),
--                                 CAST(c.NewTransactionDate AS DATE),
--                                 pnt.Name,
--                                 pnt.ProviderId,
--                                 c.ReceiptNewNumber,
--                                 c.RefundFee
--                    ) AS Query
--                ) AS QueryFinal;
--         IF OBJECT_ID('#TempTableCancel2') IS NOT NULL
--             BEGIN
--                 DROP TABLE #TempTableCancel2;
--         END;
--         CREATE TABLE #TempTableCancel2
--         (RowNumber      INT,
--          Date           DATETIME,
--          CancellationId INT,
--          Type           VARCHAR(1000),
--          TypeId         INT,
--          Provider       VARCHAR(1000),
--          ProviderId     INT,
--          Receipt        VARCHAR(1000),
--          ClientName     VARCHAR(1000),
--          TransferAmount DECIMAL(18, 2),
--          TransferFees   DECIMAL(18, 2),
--          Credit         DECIMAL(18, 2),
--          SumDetail      DECIMAL(18, 2),
--          Balance        DECIMAL(18, 2)
--         );
--         IF OBJECT_ID('#TempTableCancel3') IS NOT NULL
--             BEGIN
--                 DROP TABLE #TempTableCancel3;
--         END;
--         CREATE TABLE #TempTableCancel3
--         (CreationDate DATETIME,
--          Month        INT,
--          Year         INT,
--          Usd          DECIMAL(18, 2)
--         );
--         INSERT INTO #TempTableCancel3
--         (CreationDate,
--          Month,
--          Year,
--          Usd
--         )
--                SELECT ProviderCommissionPayments.CreationDate,
--                       ProviderCommissionPayments.Month,
--                       ProviderCommissionPayments.Year,
--                       ISNULL(ProviderCommissionPayments.Usd, 0) Usd
--                FROM dbo.ProviderCommissionPayments
--                     INNER JOIN dbo.Providers ON dbo.ProviderCommissionPayments.ProviderId = dbo.Providers.ProviderId
--                     INNER JOIN dbo.ProviderCommissionPaymentTypes ON dbo.ProviderCommissionPayments.ProviderCommissionPaymentTypeId = dbo.ProviderCommissionPaymentTypes.ProviderCommissionPaymentTypeId
--                     INNER JOIN dbo.Agencies ON dbo.ProviderCommissionPayments.AgencyId = dbo.Agencies.AgencyId
--                     LEFT OUTER JOIN dbo.Bank ON dbo.ProviderCommissionPayments.BankId = dbo.Bank.BankId
--                     INNER JOIN dbo.ProviderTypes ON dbo.ProviderTypes.ProviderTypeId = dbo.Providers.ProviderTypeId
--                WHERE ProviderCommissionPayments.AgencyId = @AgencyId
--                      AND ProviderCommissionPayments.Year >= @YearFrom
--                      AND ProviderCommissionPayments.Month >= @MonthFrom
--                      AND ProviderCommissionPayments.Year <= @YearTo
--                      AND ProviderCommissionPayments.Month <= @MonthTo
--                      AND ProviderCommissionPayments.ProviderId = @ProviderId;
--         IF EXISTS
--         (
--             SELECT 1
--             FROM #TempTableCancel3
--         )
--             BEGIN 
--	       --DROP TABLE #TempTable;
--
--                 INSERT INTO #TempTableCancel2
--                 (RowNumber,
--                  Date,
--                  CancellationId,
--                  Type,
--                  TypeId,
--                  Provider,
--                  ProviderId,
--                  Receipt,
--                  ClientName,
--                  TransferAmount,
--                  TransferFees,
--                  Credit,
--                  SumDetail,
--                  Balance
--                 )
--                        SELECT RowNumber,
--                               Date,
--                               CancellationId,
--                               Type,
--                               TypeId,
--                               Provider,
--                               ProviderId,
--                               Receipt,
--                               ClientName,
--                               TransferAmount,
--                               TransferFees,
--                               Credit,
--                               SumDetail,
--                        (
--                            SELECT SUM(t2.SumDetail)
--                            FROM #TempTableCancel t2
--                            WHERE T2.RowNumber <= T1.RowNumber
--                        ) Balance
--                        FROM #TempTableCancel t1;
--                 SELECT RowNumber,
--                        Date,
--                        CancellationId,
--                        Type,
--                        TypeId,
--                        Provider,
--                        ProviderId,
--                        Receipt,
--                        ClientName,
--                        TransferAmount,
--                        TransferFees,
--                        Credit,
--                        SumDetail,
--                        Balance
--                 FROM #TempTableCancel2
--                 UNION ALL
--                 SELECT
--                 (
--                     SELECT COUNT(*) + 1
--                     FROM #TempTableCancel2
--                 ),
--                 CAST(t.CreationDate AS DATE) Date,
--                 0 CancellationId, 
--                 --'COMMISSIONS'+CAST(T.Month AS CHAR(2))+'-'+CAST(T.Year AS CHAR(4)) Type,
--                 'COMMISSIONS' Type,
--                 3 TypeId,
--                 '-' Provider,
--                 0 ProviderId,
--                 '-' Receipt,
--                 '-' ClientName,
--                 0 TransferAmount,
--                 0 TransferFees,
--                 T.Usd Credit,
--                 0 SumDetail,
--                 0 Balance
--                 FROM #TempTableCancel3 T;
--                 --ORDER BY RowNumber ASC;
--         END;
--             ELSE
--             BEGIN 
--	       --DROP TABLE #TempTable;
--
--                 INSERT INTO #TempTableCancel2
--                 (RowNumber,
--                  Date,
--                  CancellationId,
--                  Type,
--                  TypeId,
--                  Provider,
--                  ProviderId,
--                  Receipt,
--                  ClientName,
--                  TransferAmount,
--                  TransferFees,
--                  Credit,
--                  SumDetail,
--                  Balance
--                 )
--                 SELECT *,
--                 (
--                     SELECT SUM(t2.SumDetail)
--                     FROM #TempTableCancel t2
--                     WHERE T2.RowNumber <= T1.RowNumber
--                 ) Balance
--                 FROM #TempTableCancel t1;
--                 SELECT *
--                 FROM #TempTableCancel2
--                 ORDER BY RowNumber ASC;
--         END;
--     END;





GO