SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:22-09-2023
--CAMBIOS EN 5399, Refactoring reporte de surplus

-- =============================================
-- Author:      sa
-- Create date: 15/07/2024 6:13 p. m.
-- Database:    copiaDevtest
-- Description: task 5905 Comisión pagada en 0.00 debe reflejarse en el reporte
-- =============================================

CREATE   PROCEDURE [dbo].[sp_GetReportSurplusDetail] (@AgencyId INT,
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
  SET @BalanceDetail = (SELECT
      SUM(BalanceDetail)
    FROM dbo.FN_GenerateSurplusDetailReport(@AgencyId, '1985-01-01', @initialBalanceFinalDate))


  CREATE TABLE #Temp (
    [ID] INT IDENTITY (1, 1)
   ,[Index] INT
   ,AgencyId INT
   ,Date DATETIME
   ,Employee VARCHAR(1000)

   ,Type VARCHAR(1000)
   ,TypeId INT
      ,UserBeneficaryId INT
   ,Usd DECIMAL(18, 2)
   ,Credit DECIMAL(18, 2)
   ,BalanceDetail DECIMAL(18, 2)

  )
  INSERT INTO #Temp
    SELECT
      0 [Index]
     ,@AgencyId AgencyId
     ,CAST(@initialBalanceFinalDate AS Date) Date
     ,'-' Employee
     ,'INITIAL BALANCE' Type
     ,1 TypeId
     ,0 UserBeneficaryId
     ,0 Usd
     ,0 Credit
     ,ISNULL(@BalanceDetail, 0) BalanceDetail

    UNION ALL

    SELECT
      *
    FROM [dbo].FN_GenerateSurplusDetailReport(@AgencyId, @FromDate, @ToDate)
    ORDER BY Date;
    


  SELECT
    *
   ,(SELECT
        ISNULL(SUM(BalanceDetail), 0)
      FROM #Temp T2
      WHERE T2.[Index] <= T1.[Index]
      AND ((T2.BalanceDetail > 0
      OR T2.BalanceDetail < 0) OR T2.TypeId = 2))
    BalanceFinal
  FROM #Temp T1
  WHERE ((T1.BalanceDetail > 0
  OR T1.BalanceDetail < 0) OR T1.TypeId = 2)
  ORDER BY T1.ID ASC;
  DROP TABLE #Temp

END
GO