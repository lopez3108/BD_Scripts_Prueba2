SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:25-09-2023
--CAMBIOS EN 5400,Refactorizacion de reporte cancellation
CREATE PROCEDURE [dbo].[sp_GetReportCancellationsPendings] (@AgencyId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL,
@Date DATETIME)
AS
BEGIN

  CREATE TABLE #Temp (
    [ID] INT IDENTITY(1,1),
    [Index] INT
   ,Date DATETIME
   ,Type VARCHAR(1000)
   ,CancellationId INT
   ,Provider VARCHAR(1000)
   ,ProviderId INT
   ,Receipt VARCHAR(1000)
   ,ClientName VARCHAR(1000)
   ,TransferAmount DECIMAL(18, 2)
   ,TransferFees DECIMAL(18, 2)
  
   ,SumDetail DECIMAL(18, 2)
   ,Balance DECIMAL(18, 2)


  )

  INSERT INTO #Temp


    SELECT
      *
    FROM [dbo].FN_GeneratePendingCancellationReport(@AgencyId, @FromDate, @ToDate)
    ORDER BY Date,
    [Index];



  SELECT
    *
  --  				 (
  --              SELECT ISNULL( SUM(t2.Balance), 0)
  --              FROM    #Temp T2
  --              WHERE T2.[Index] <= T1.[Index]
  --          ) Balance
  FROM #Temp T1

  DROP TABLE #Temp






--         --IF(@FromDate IS NULL)
--             --BEGIN
--                 --SET @FromDate = DATEADD(day, -10, @Date);
--                 --SET @ToDate = @Date;
--         --END;
--         SELECT CAST(c.CancellationDate AS DATE) Date,
--                'PENDING' Type,
--                c.CancellationId,
--                CASE
--                    WHEN ct.Code = 'C01'
--                    THEN p.Name+' (M.T)'
--                    WHEN ct.Code = 'C02'
--                    THEN p.Name+' (M.O)'
--					ELSE
--								   p.Name
--                END Provider,
--                p.ProviderId,
--                c.ReceiptCancelledNumber Receipt,
--                c.ClientName,
--                ABS(SUM(c.TotalTransaction)) TransferAmount,
--                ABS(SUM(c.Fee)) TransferFees,
--                (SUM(ABS(c.TotalTransaction)) + SUM(ABS(c.Fee))) SumDetail,
--         (
--             SELECT(SUM(ABS(C1.TotalTransaction)) + SUM(ABS(C1.Fee)))
--             FROM Cancellations c1
--                  INNER JOIN Providers p ON p.ProviderId = c1.ProviderCancelledId
--             WHERE c1.AgencyId = @AgencyId
--                   AND CAST(c1.CancellationDate AS DATE) <= CAST(c.CancellationDate AS DATE)
--                   AND c1.CancellationId <= c.CancellationId
--                   AND c1.RefundDate IS NULL
--                   AND c1.NewTransactionDate IS NULL
--
--         ) Balance
--         FROM Cancellations c
--              INNER JOIN Providers p ON p.ProviderId = c.ProviderCancelledId
--              LEFT JOIN CancellationTypes ct ON CT.CancellationTypeId = c.CancellationTypeId
--         WHERE c.AgencyId = @AgencyId
--               AND ((CAST(c.CancellationDate AS DATE) >= CAST(@FromDate AS DATE)
--               AND CAST(c.CancellationDate AS DATE) <= CAST(@ToDate AS DATE)) OR @FromDate is null)
--               AND RefundDate IS NULL
--               AND NewTransactionDate IS NULL
--         GROUP BY CAST(c.CancellationDate AS DATE),
--                  p.ProviderId,
--                  p.Name,
--                  ct.Code,
--                  c.AgencyId,
--                  c.ReceiptCancelledNumber,
--                  c.ClientName,
--                  c.CancellationId,
--                  c.CancellationDate
--         ORDER BY c.CancellationId ASC;
END;

GO