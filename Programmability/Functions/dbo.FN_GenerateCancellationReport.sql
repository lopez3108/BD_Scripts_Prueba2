SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:24-10-2023
--CAMBIOS EN 5463, cambiar fecha de  pago de comisiones

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:25-09-2023
--CAMBIOS EN 5400,Refactorizacion de reporte cancellation

-- =============================================
-- Author:      JF
-- Create date: 21/06/2024 3:45 p. m.
-- Database:    copiaDevtest
-- Description: task 5905  Comisión pagada en 0.00 debe reflejarse en el reporte
-- =============================================



CREATE FUNCTION [dbo].[FN_GenerateCancellationReport] (@AgencyId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL
)
RETURNS @result TABLE (
  [Index] INT
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


AS




BEGIN

 DECLARE @YearFrom AS INT, @YearTo AS INT, @MonthFrom AS INT, @MonthTo AS INT, @ProviderId AS INT;
  SET @YearFrom = CAST(YEAR(CAST(@FromDate AS DATE)) AS VARCHAR(10));
         SET @YearTo = CAST(YEAR(CAST(@ToDate AS DATE)) AS VARCHAR(10));
         SET @MonthFrom = CAST(MONTH(CAST(@FromDate AS DATE)) AS VARCHAR(10));
         SET @MonthTo = CAST(MONTH(CAST(@ToDate AS DATE)) AS VARCHAR(10));
            SET @ProviderId =
         (
             SELECT TOP 1 ProviderId
             FROM Providers
                  INNER JOIN ProviderTypes ON Providers.ProviderTypeId = ProviderTypes.ProviderTypeId
             WHERE ProviderTypes.Code = 'C06'
                   AND Providers.Active = 1
         );

  INSERT INTO @result
    SELECT
      ROW_NUMBER() OVER (ORDER BY CAST(Query.Date AS Date) ASC,
      Query.CancellationId ASC,
      Query.TypeId ASC,
      Query.ClientName ASC) [Index]
     ,*
    FROM (
     
      SELECT
        CAST(c.CancellationDate AS Date) Date
       ,c.CancellationId
       ,'CANCELED' Type
       ,2 TypeId
       ,CASE
          WHEN ct.Code = 'C01' THEN p.Name + ' (M.T)'
          WHEN ct.Code = 'C02' THEN p.Name + ' (M.O)'
          ELSE p.Name
        END Provider
       ,p.ProviderId
       ,c.ReceiptCancelledNumber Receipt
       ,c.ClientName
       ,ABS(SUM(c.TotalTransaction)) TransferAmount
       ,ABS(SUM(c.Fee)) TransferFees
       ,0 Credit
       ,(SUM(ABS(c.TotalTransaction)) + SUM(ABS(c.Fee))) SumDetail
       ,NULL [Month]
       ,NULL [Year]
      FROM Cancellations c
      INNER JOIN Providers p
        ON p.ProviderId = c.ProviderCancelledId
      LEFT JOIN CancellationTypes ct
        ON ct.CancellationTypeId = c.CancellationTypeId
      WHERE c.AgencyId = @AgencyId
      AND CAST(c.CancellationDate AS Date) >= CAST(@FromDate AS Date)
      AND CAST(c.CancellationDate AS Date) <= CAST(@ToDate AS Date)
      AND (RefundDate IS NOT NULL
      OR NewTransactionDate IS NOT NULL)
      GROUP BY CAST(c.CancellationDate AS Date)
              ,p.ProviderId
              ,p.Name
              ,ct.Code
              ,c.ReceiptCancelledNumber
              ,c.ClientName
              ,c.CancellationId
              ,c.CancellationDate
      UNION ALL
      SELECT
        CAST(c.CancellationDate AS Date) Date
       ,c.CancellationId
       ,CASE
          WHEN CAST(c.RefundDate AS Date) IS NOT NULL AND
            RefundFee = 1 THEN 'REFUND (FEE)'
          WHEN CAST(c.RefundDate AS Date) IS NOT NULL AND
            (RefundFee IS NULL OR
            RefundFee = 0)

          --WHEN CAST(c.RefundDate AS DATE) IS NOT NULL
          THEN 'REFUND'
          WHEN CAST(c.NewTransactionDate AS Date) IS NOT NULL THEN 'NEW TRASACCION'
        END AS Type
       ,3 TypeId
       ,CASE
          WHEN CAST(c.RefundDate AS Date) IS NOT NULL THEN '-'
          WHEN CAST(c.NewTransactionDate AS Date) IS NOT NULL AND
            ct.Code = 'C01' THEN pnt.Name + '(M.T)'
          WHEN CAST(c.NewTransactionDate AS Date) IS NOT NULL AND
            ct.Code = 'C02' THEN pnt.Name + ' (M.O)'
          ELSE pnt.Name
        END AS Provider
       ,CASE
          WHEN CAST(c.RefundDate AS Date) IS NOT NULL THEN ISNULL(p.ProviderId, 0)
          WHEN CAST(c.NewTransactionDate AS Date) IS NOT NULL THEN ISNULL(pnt.ProviderId, 0)
        END AS ProviderId
       ,CASE
          WHEN CAST(c.RefundDate AS Date) IS NOT NULL THEN c.ReceiptCancelledNumber
          WHEN CAST(c.NewTransactionDate AS Date) IS NOT NULL THEN c.ReceiptNewNumber
        END AS Receipt
       ,c.ClientName
       ,0 TransferAmount
       ,0 TransferFees
       ,CASE
          WHEN CAST(c.RefundDate AS Date) IS NOT NULL AND
            RefundFee = 1 THEN ISNULL((SUM(ABS(c.RefundAmount)) + SUM(ABS(c.Fee))),0)
          WHEN CAST(c.RefundDate AS Date) IS NOT NULL AND
            (RefundFee IS NULL OR
            RefundFee = 0) THEN ISNULL(SUM(ABS(c.RefundAmount)),0)
          WHEN CAST(c.NewTransactionDate AS Date) IS NOT NULL THEN ISNULL((SUM(ABS(c.TotalTransaction)) + SUM(ABS(c.Fee))),0)
        END AS Credit
       ,CASE
          WHEN CAST(c.RefundDate AS Date) IS NOT NULL AND
            RefundFee = 1 THEN ISNULL(-(SUM(ABS(c.RefundAmount)) + SUM(ABS(c.Fee))),0)
          WHEN CAST(c.RefundDate AS Date) IS NOT NULL AND
            (RefundFee IS NULL OR
            RefundFee = 0) THEN ISNULL(-SUM(ABS(c.RefundAmount)),0)
          WHEN CAST(c.NewTransactionDate AS Date) IS NOT NULL THEN ISNULL(-(SUM(ABS(c.TotalTransaction)) + SUM(ABS(c.Fee))),0)
        END AS SumDetail
       ,NULL [Month]
       ,NULL [Year]
      FROM Cancellations c
      INNER JOIN Providers p
        ON p.ProviderId = c.ProviderCancelledId
      LEFT JOIN Providers pnt
        ON pnt.ProviderId = c.ProviderNewId
      LEFT JOIN CancellationTypes ct
        ON ct.CancellationTypeId = c.CancellationTypeId
      WHERE c.AgencyId = @AgencyId
      AND CAST(c.CancellationDate AS Date) >= CAST(@FromDate AS Date)
      AND CAST(c.CancellationDate AS Date) <= CAST(@ToDate AS Date)
      AND (RefundDate IS NOT NULL
           OR NewTransactionDate IS NOT NULL)
--      comentado por romario en base a lo pedido en la task 5553
--      AND ((CAST(c.RefundDate AS Date) >= CAST(@FromDate AS Date)
--      AND CAST(c.RefundDate AS Date) <= CAST(@ToDate AS Date))
--      OR (CAST(c.NewTransactionDate AS Date) >= CAST(@FromDate AS Date)
--      AND CAST(c.NewTransactionDate AS Date) <= CAST(@ToDate AS Date)))
      --AND (RefundDate IS NOT NULL
      --     OR NewTransactionDate IS NOT NULL)
      GROUP BY CAST(c.CancellationDate AS Date)
              ,p.ProviderId
              ,p.Name
              ,ct.Code
              ,c.ReceiptCancelledNumber
              ,c.ClientName
              ,c.CancellationId
              ,c.CancellationDate
              ,CAST(c.RefundDate AS Date)
              ,CAST(c.NewTransactionDate AS Date)
              ,pnt.Name
              ,pnt.ProviderId
              ,c.ReceiptNewNumber
              ,c.RefundFee) AS Query



  INSERT INTO @result

    SELECT
      (SELECT
          COUNT(*) + 1
        FROM @result)
      [Index]
      	 ,dbo.[fn_GetNextDayPeriod](Year, Month) Date
--     ,CAST(ProviderCommissionPayments.CreationDate AS Date) Date
     ,0 CancellationId
     ,'COMMISSIONS' Type
     ,3 TypeId
     ,'COMM. ' + dbo.[fn_GetMonthByNum](Month) + '-' + CAST(Year AS CHAR(4))  Provider
     ,0 ProviderId
     ,'-' Receipt
     ,'-' ClientName
     ,0 TransferAmount
     ,0 TransferFees
     ,Usd Credit
--     ,Usd Credit comentado por romario en base a lo pedido en la task 5553
     ,-Usd SumDetail
     ,ProviderCommissionPayments.Month
     ,ProviderCommissionPayments.Year
    FROM dbo.ProviderCommissionPayments
    INNER JOIN dbo.Providers
      ON dbo.ProviderCommissionPayments.ProviderId = dbo.Providers.ProviderId
    INNER JOIN dbo.ProviderCommissionPaymentTypes
      ON dbo.ProviderCommissionPayments.ProviderCommissionPaymentTypeId = dbo.ProviderCommissionPaymentTypes.ProviderCommissionPaymentTypeId
    INNER JOIN dbo.Agencies
      ON dbo.ProviderCommissionPayments.AgencyId = dbo.Agencies.AgencyId
    LEFT OUTER JOIN dbo.Bank
      ON dbo.ProviderCommissionPayments.BankId = dbo.Bank.BankId
    INNER JOIN dbo.ProviderTypes
      ON dbo.ProviderTypes.ProviderTypeId = dbo.Providers.ProviderTypeId
    WHERE ProviderCommissionPayments.AgencyId = @AgencyId
        AND (dbo.[fn_GetNextDayPeriod](Year, Month) >= CAST(@FromDate AS DATE)
        OR @FromDate IS NULL)
        AND (dbo.[fn_GetNextDayPeriod](Year, Month) <= CAST(@ToDate AS DATE)
        OR @ToDate IS NULL)
--    AND ProviderCommissionPayments.Year >= @YearFrom
--    AND ProviderCommissionPayments.Month >= @MonthFrom
--    AND ProviderCommissionPayments.Year <= @YearTo
--    AND ProviderCommissionPayments.Month <= @MonthTo
    AND ProviderCommissionPayments.ProviderId = @ProviderId;



  RETURN;
END;

GO