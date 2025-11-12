SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:22-09-2023
--CAMBIOS EN 5397,Refactorizacion de reporte missing

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:30-11-2023
--CAMBIOS EN 5355, Se agrega balance inicial a filtrado por fechas

--UPDATE DATE: 29-04-2024
--UPDATE BY: JT
--USO: REFACTORING QUERY PAYMENTS DETAILS MAKE BY DATE , NOW THE INFO IT'S GET FROM CENTRALIZERS FN FN_GenerateOnyMissingDetailReport AND  FN_GenerateOnyMissingPaymentsDetailReport 
-- 2025-07-15 JT/6603: Missing payments managers


CREATE PROCEDURE [dbo].[sp_GetReportMissing] (@AgencyId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL,
@Date DATETIME,
@CodeFilter VARCHAR(3) = NULL)
AS
BEGIN
  IF (@FromDate IS NULL)
  BEGIN
    SET @FromDate = DATEADD(DAY, -10, @Date);
    SET @ToDate = @Date;
  END;

  IF (@CodeFilter = 'C02')-- Solo para rangos de fecha --
  BEGIN
    DECLARE @initialBalanceFinalDate DATETIME
    SET @initialBalanceFinalDate = DATEADD(DAY, -1, @FromDate)
    DECLARE @BalanceDetail DECIMAL(18, 2)
    SET @BalanceDetail = (ISNULL((SELECT
        SUM(CAST(BalanceDetail AS DECIMAL(18, 2)))
      FROM dbo.FN_GenerateOnyMissingDetailReport(@AgencyId, '1985-01-01', @initialBalanceFinalDate, @CodeFilter, NULL, NULL))
    , 0)
    - ISNULL((SELECT
        SUM(CAST(BalanceDetail AS DECIMAL(18, 2)))
      FROM dbo.FN_GenerateOnyMissingPaymentsDetailReport(@AgencyId, '1985-01-01', @initialBalanceFinalDate, @CodeFilter, NULL, NULL))
    , 0)
    )
  END

  CREATE TABLE #Temp (

    [Index] INT
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
      ROW_NUMBER() OVER (
      ORDER BY CAST(Query.Date AS Date),
      Query.TypeId ASC) [Index]
     ,Query.AgencyId
     ,Query.Date
     ,Query.Description
     ,Query.Type
     ,Query.TypeId
     ,(Query.Usd) Usd
     ,Query.Credit
     ,(Query.BalanceDetail) BalanceDetail
    FROM (SELECT
        @AgencyId AS AgencyId
       ,CAST(@initialBalanceFinalDate AS Date) Date
       ,'INITIAL BALANCE' Description
       ,'INITIAL BALANCE' Type
       ,1 TypeId
       ,0 Usd
       ,0 Credit
       ,@BalanceDetail BalanceDetail

      UNION ALL
      SELECT
        AgencyId
       ,CAST(Date AS Date) Date
       ,'CLOSING DAILY' Description
       ,Type
       ,TypeId
       ,SUM(ISNULL(Usd, 0)) Usd
       ,SUM(ISNULL(Credit, 0)) Credit
       ,SUM(ISNULL(BalanceDetail, 0)) BalanceDetail
      FROM [dbo].FN_GenerateOnyMissingDetailReport(@AgencyId, @FromDate, @ToDate, @CodeFilter, NULL, NULL)
      GROUP BY AgencyId
              ,CAST(Date AS Date)
              ,Type
              ,TypeId
      UNION ALL
      SELECT
        AgencyId
       ,CAST(Date AS Date) Date
       ,'CLOSING DAILY' Description
       ,Type
       ,TypeId
       ,SUM(ISNULL(Usd, 0)) Usd
       ,SUM(ISNULL(Credit, 0)) Credit
       ,-SUM(ISNULL(BalanceDetail, 0)) BalanceDetail
      FROM [dbo].FN_GenerateOnyMissingPaymentsDetailReport(@AgencyId, @FromDate, @ToDate, @CodeFilter, NULL, NULL)

      GROUP BY AgencyId
              ,CAST(Date AS Date)
              ,Type
              ,TypeId) AS Query

    ORDER BY Date,
    [Index];
  SELECT
    *
   ,((SELECT
        SUM((t2.BalanceDetail))
      FROM #Temp t2
      WHERE t2.[Index] <= t1.[Index]
      AND (t2.BalanceDetail < 0
      OR t2.BalanceDetail > 0))
    ) BalanceFinal
  FROM #Temp t1
  WHERE (t1.BalanceDetail < 0
  OR t1.BalanceDetail > 0)
  ORDER BY [Index] ASC
  DROP TABLE #Temp
END;



GO