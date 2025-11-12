SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:22-09-2023
--CAMBIOS EN 5397,Refactorizacion de reporte missing

--UPDATE DATE: 29-04-2024
--UPDATE BY: JT
--USO: REFACTORING QUERY PAYMENTS DETAILS MAKE BY DATE , NOW THE INFO IT'S GET FROM CENTRALIZERS FN FN_GenerateOnyMissingDetailReport AND  FN_GenerateOnyMissingPaymentsDetailReport 

-- 2025-07-16 JT/6603: Missing payments managers

CREATE PROCEDURE [dbo].[sp_GetReportMissingPendingEmployee] (
@AgencyId VARCHAR(100) = NULL,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL,
@Date DATETIME,
@CodeFilter VARCHAR(3) = NULL,
@CashierId INT = NULL
,@UserManagerId INT = NULL  )
AS
BEGIN
  IF (@FromDate IS NULL)
  BEGIN
    SET @FromDate = DATEADD(DAY, -10, @Date);
    SET @ToDate = @Date;
  END;

  CREATE TABLE #Temp (

    [Index] INT
   ,AgencyId INT
   ,Type VARCHAR(1000)
   ,TypeId INT
   ,Employee VARCHAR(1000)
   ,CashierId INT
   ,TotalDays INT
   ,Usd DECIMAL(18, 2)
   ,BalanceDetail DECIMAL(18, 2)
  )

  INSERT INTO #Temp

    SELECT
      ROW_NUMBER() OVER (ORDER BY Query.Employee ASC) [Index]
     ,Query.AgencyId
     ,Query.Type
     ,Query.TypeId
     ,Query.Employee
     ,Query.CashierId
     ,Query.TotalDays
     ,CASE
        WHEN @CodeFilter = 'C01' --Para pending de una vez consultamos el balance final del missing
        THEN (SELECT
              [dbo].FN_GenerateBalanceMissing(AgencyId, Query.CashierId, NULL,NULL, @UserManagerId))
        ELSE (Query.Usd)
      END Usd
     ,CASE
        WHEN @CodeFilter = 'C01' --Para pending de una vez consultamos el balance final del missing
        THEN (SELECT
              [dbo].FN_GenerateBalanceMissing(AgencyId, Query.CashierId, NULL,NULL, @UserManagerId))
        ELSE (Query.BalanceDetail)
      END
      BalanceDetail
    FROM (SELECT
        AgencyId
       ,'MISSING' AS Type
       ,TypeId
       ,Employee
       ,CashierId
       ,COUNT(Date) TotalDays
       ,SUM(ISNULL(Usd, 0))
        Usd
       ,SUM(ISNULL(BalanceDetail, 0)) BalanceDetail
      FROM [dbo].FN_GenerateOnyMissingDetailReport(@AgencyId, @FromDate, @ToDate, @CodeFilter, @CashierId, @UserManagerId)
      GROUP BY AgencyId
              ,Employee
              ,TypeId
              ,CashierId
      UNION ALL
      SELECT
        AgencyId
       ,'PAYMENT' Type
       ,TypeId
       ,Employee
       ,CashierId
       ,0 TotalDays
       ,SUM(ISNULL(Credit, 0)) Usd
       ,-SUM(ISNULL(BalanceDetail, 0)) BalanceDetail
      FROM [dbo].FN_GenerateOnyMissingPaymentsDetailReport(@AgencyId, @FromDate, @ToDate, @CodeFilter, @CashierId, @UserManagerId)
      WHERE @CodeFilter = 'C02'
      GROUP BY AgencyId
              ,Employee
              ,TypeId
              ,CashierId) AS Query
    ORDER BY [Index];

  --    SELECT
  --      *
  --    FROM [dbo].FN_GenerateMissingPendingEmployee(@AgencyId, @FromDate, @ToDate, @CodeFilter, @CashierId)
  --    ORDER BY [Index];
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