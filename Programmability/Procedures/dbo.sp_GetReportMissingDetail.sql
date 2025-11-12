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

CREATE PROCEDURE [dbo].[sp_GetReportMissingDetail] (@AgencyId INT,
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


  IF (@CodeFilter = 'C02')-- Solo para rangos de fecha
  BEGIN
    DECLARE @initialBalanceFinalDate DATETIME
    SET @initialBalanceFinalDate = DATEADD(DAY, -1, @FromDate)
    DECLARE @BalanceDetail DECIMAL(18, 2)
    SET @BalanceDetail = (ISNULL((SELECT
        SUM(CAST(BalanceDetail AS DECIMAL(18, 2)))
      FROM dbo.FN_GenerateOnyMissingDetailReport(@AgencyId, '1985-01-01', @initialBalanceFinalDate, @CodeFilter, NULL, NULL)),0)
    - ISNULL((SELECT
        SUM(CAST(BalanceDetail AS DECIMAL(18, 2)))
      FROM dbo.FN_GenerateOnyMissingPaymentsDetailReport(@AgencyId, '1985-01-01', @initialBalanceFinalDate, @CodeFilter, NULL, NULL )),0)
    )


  END

  CREATE TABLE #Temp (

    [Index] INT
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

  --  IF (@CodeFilter = 'C02') --RANGO DE FECHAS
  --  BEGIN
  INSERT INTO #Temp
    SELECT
      ROW_NUMBER() OVER (
      ORDER BY
      Query.Date ASC,
         Query.TypeId ASC,
      Query.UserBeneficaryId ASC
   
      ) [Index]
     ,Query.AgencyId
     ,Query.Date
     ,Query.Employee
     ,Query.Type
     ,Query.TypeId
     ,Query.UserBeneficaryId
     ,(Query.Usd) Usd
     ,Query.Credit
     ,(Query.BalanceDetail) BalanceDetail
    FROM (SELECT
        @AgencyId AS AgencyId
       ,CAST(@initialBalanceFinalDate AS Date) Date
       ,'INITIAL BALANCE' Employee
       ,'INITIAL BALANCE' Type
       ,1 TypeId
       ,0 UserBeneficaryId
       ,0 Usd
       ,0 Credit
       ,@BalanceDetail BalanceDetail

      UNION ALL
      SELECT
        AgencyId
       ,Date
       ,Employee
       ,Type
       ,TypeId
       ,UserBeneficaryId
       ,Usd
       ,Credit
       ,BalanceDetail
      FROM [dbo].FN_GenerateOnyMissingDetailReport(@AgencyId, @FromDate, @ToDate, @CodeFilter, NULL, NULL )

      UNION ALL
      SELECT
        AgencyId
       ,Date
       ,Employee
       ,Type
       ,TypeId
       ,UserBeneficaryId
       ,Usd
       ,Credit
       ,-BalanceDetail
      FROM [dbo].FN_GenerateOnyMissingPaymentsDetailReport(@AgencyId, @FromDate, @ToDate, @CodeFilter, NULL, NULL )) AS Query
    ORDER BY [Index];
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
  ORDER BY [Index] ASC;
END



GO