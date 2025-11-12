SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      sa
-- Create date: 15/07/2024 6:14 p. m.
-- Database:    copiaDevtest
-- Description: task 5905 Comisión pagada en 0.00 debe reflejarse en el reporte
-- =============================================

CREATE PROCEDURE [dbo].[sp_GetReportSurplus] (@AgencyId INT,
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
  DECLARE @BalanceDetail DECIMAL(18, 2)
  SET @BalanceDetail = (SELECT SUM(BalanceDetail) FROM dbo.FN_GenerateSurplusReport(@AgencyId, '1985-01-01', @initialBalanceFinalDate))


  CREATE TABLE #Temp (
    [ID] INT IDENTITY (1, 1)
   ,[Index] INT
   ,AgencyId INT
   ,Date DATETIME
   ,Description VARCHAR(1000)
   ,Type VARCHAR(1000)
   ,TypeId INT
   ,Usd DECIMAL(18, 2)
   ,Credit DECIMAL(18, 2)
   ,BalanceDetail DECIMAL(18, 2)

  )


  INSERT INTO #Temp
    SELECT
      0 [Index]
     ,@AgencyId AgencyId
     ,CAST(@initialBalanceFinalDate AS Date) Date
     ,'INITIAL BALANCE' Description
     ,'INITIAL BALANCE' Type
     ,0 TypeId
     ,0 Usd
     ,0 Credit
     ,@BalanceDetail BalanceDetail

    UNION ALL

    SELECT
      *
    FROM [dbo].FN_GenerateSurplusReport(@AgencyId, @FromDate, @ToDate)
    ORDER BY Date;
   



 
  SELECT
    *
   ,(SELECT
        ISNULL(SUM(BalanceDetail), 0)
      FROM #Temp T2
      WHERE T2.[Index] <= T1.[Index] AND ((T2.BalanceDetail > 0
      OR T2.BalanceDetail < 0) OR T2.TypeId = 1))
    BalanceFinal
  FROM #Temp T1
  WHERE ((T1.BalanceDetail > 0
  OR T1.BalanceDetail < 0) OR T1.TypeId = 1)
     ORDER BY T1.ID ASC;
  DROP TABLE #Temp
END
GO