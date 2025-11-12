SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetReportAdjustment]
(
                 @AgencyId int = NULL, @FromDate datetime = NULL, @ToDate datetime = NULL, @Date datetime
)
AS
BEGIN

  IF (@FromDate IS NULL)
  BEGIN
    SET @FromDate = DATEADD(DAY, -10, @Date);
    SET @ToDate = @Date;
  END;

--  IF OBJECT_ID('#TempTableAdjustment') IS NOT NULL
--  BEGIN
--    DROP TABLE #TempTableAdjustment;
--  END;

  -- INITIAL BALANCE

  DECLARE @initialBalanceFinalDate datetime
  SET @initialBalanceFinalDate = DATEADD(DAY, -1, @FromDate)


  DECLARE @Balance decimal(18, 2)
  SET @Balance = ISNULL((SELECT SUM(CAST(BalanceDetail AS DECIMAL(18, 2)))
FROM dbo.FN_GetReportAdjustment(@AgencyId, '1985-01-01', @initialBalanceFinalDate)),0)

  CREATE TABLE #TempTableAdjustment
  (
              [ID] int IDENTITY (1, 1),
              RowNumber int,
              PaymentAdjustmentId int,
              AgencyFromId int,
              AgencyToId int,
              Date date,
              Type varchar(1000),
              TypeId int,
              Description varchar(1000),
              Debit decimal(18, 2) NULL,
              Credit decimal(18, 2) NULL,
              ProviderId int,
              BalanceDetail decimal(18, 2) NULL
  );


  INSERT INTO #TempTableAdjustment
         SELECT 0 RowNumber,
         NULL PaymentAdjustmentId,
         NULL AgencyFromId,
         NULL AgencyToId,
         CAST(@initialBalanceFinalDate AS DATE) Date,
         'INITIAL BALANCE' Type,
         0 TypeId,
         'INITIAL BALANCE' Description,
         0 Debit,
         0 Credit,
         0 ProviderId,
         ISNULL(@Balance, 0) BalanceDetail
          

         UNION ALL
     

         SELECT *
         FROM [dbo].FN_GetReportAdjustment(@AgencyId, @FromDate, @ToDate)
         ORDER BY Date,
         RowNumber;

--  SELECT *, (SELECT SUM(t2.BalanceDetail)
--FROM #TempTableAdjustment t2
--WHERE t2.RowNumber <= t1.RowNumber) BalanceFinal
--  FROM #TempTableAdjustment t1
--  ORDER BY RowNumber ASC;
--   DROP TABLE #TempTableAdjustment
	SELECT 
  				 *,
  				 (
              SELECT ISNULL( SUM(CAST(BalanceDetail AS DECIMAL(18, 2))), 0)
              FROM #TempTableAdjustment t2
              WHERE t2.RowNumber <= t1.RowNumber
          ) BalanceFinal
          	
  				 FROM #TempTableAdjustment T1

           ORDER BY RowNumber ASC;

  
END;



GO