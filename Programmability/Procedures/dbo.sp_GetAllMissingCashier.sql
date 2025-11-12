SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Update: JT
--Date:04-23-2024
--CAMBIOS EN 5785 , Permitir a un manager pagar los missings de otros cajeros

--Update: Felipe
--Date:04-12-2023
--CAMBIOS EN 5355, Mejoras Daily concilliation > MISSING'

--Update: Felipe
--Date:18-Enero-2023 task 5591
--(CASE
--        WHEN @StartingDate IS NOT NULL  THEN (SELECT -abs([dbo].FN_GeneratependingMissing(@AgencyId, @StartingDate, @CashierId))) 
--        ELSE 0

--UPDATE DATE: 29-04-2024
--UPDATE BY: JT
--USO: REFACTORING QUERY PAYMENTS DETAILS MAKE BY DATE , NOW THE INFO IT'S GET FROM CENTRALIZERS FN FN_GenerateOnyMissingDetailReport AND  FN_GenerateOnyMissingPaymentsDetailReport 

-- 2025-07-15 JT/6603: Missing payments managers

CREATE PROCEDURE [dbo].[sp_GetAllMissingCashier] (@StartingDate DATE = NULL,
@EndingDate DATE = NULL,
@UserId INT = NULL,
@AgencyId INT = NULL,
@UserManagerId INT = NULL)
AS
BEGIN
  DECLARE @CodeFilter AS VARCHAR(10);
  IF (@StartingDate IS NOT NULL) --task 5591  si la fecha es null quiere decir que es pendiente
  BEGIN
    SET @CodeFilter = 'C02'
  END
  ELSE
    SET @CodeFilter = 'C01'

  DECLARE @initialBalanceFinalDate DATETIME
  SET @initialBalanceFinalDate = DATEADD(DAY, -1, @StartingDate)

  DECLARE @CashierId AS INT;
  SET @CashierId = (SELECT
      CashierId
    FROM Cashiers c
    WHERE c.UserId = @UserId)
  IF OBJECT_ID('#TempTableCardPayment') IS NOT NULL
  BEGIN
    DROP TABLE #TempTableCardPayment;
  END;
  CREATE TABLE #TempTableCardPayment (
    RowNumber INT
    --   ,IndexType INT
    --   ,DailyAdjustmentId INT
    --   ,DailyId INT
    --   ,PaymentId INT
   ,AgencyCodeName VARCHAR(1000)
   ,USD DECIMAL(18, 2)
   ,Date DATETIME
   ,CreationDateFormat VARCHAR(1000)
   ,DatePyament DATETIME
   ,PaymentId INT
   ,[Description] VARCHAR(1000)
   ,Details VARCHAR(1000)
   ,Debt DECIMAL(18, 2)
   ,UserName VARCHAR(1000)
  );
  INSERT INTO #TempTableCardPayment (RowNumber,
  --  IndexType,
  --  DailyAdjustmentId,
  --  DailyId,
  --  PaymentId,
  AgencyCodeName,
  USD,
  Date,
  CreationDateFormat,
  DatePyament,
  PaymentId
  , [Description],
  Details,
  Debt,
  UserName)
    SELECT
      *
    FROM (SELECT
        ROW_NUMBER() OVER (
        ORDER BY CAST(Query.Date AS Date), DatePyament, OtherPaymentId ASC) RowNumber
       ,*
      FROM (SELECT
          --          IndexType
          --         DailyAdjustmentId
          --         ,DailyId
          --         ,PaymentId
          AgencyCodeName
         ,SUM(ISNULL(USD, 0)) AS USD
         ,CAST(Date AS Date) AS Date
         ,CreationDateFormat AS CreationDateFormat
         ,CAST(DatePyament AS Date) DatePyament
         ,OtherPaymentId
         ,Description [Description]
         ,Details
         ,SUM(Debt) Debt
         ,UserName
        FROM (SELECT
            NULL AgencyCodeName
           ,NULL USD
           ,CAST('01-01-1900' AS Date) AS Date
           ,FORMAT(CAST('1900-01-01' AS Date), 'MM-dd-yyyy', 'en-US') CreationDateFormat
           ,NULL AS DatePyament
           ,NULL OtherPaymentId
           ,NULL [Description]
           ,NULL Details
            -- task 5591  si la fecha es null quiere decir que es pendiente (no necesitamos inicial balance devolvemos cero ) si no devolvemos el debit a la fecha anterior a @StartingDate 
            -- ,(SELECT -abs([dbo].FN_GeneratependingMissing(@AgencyId, @StartingDate, @CashierId)))  AS Debt 
           ,(CASE
              WHEN @StartingDate IS NOT NULL THEN (ISNULL((SELECT
                    SUM(CAST(BalanceDetail AS DECIMAL(18, 2)))
                  FROM dbo.FN_GenerateOnyMissingDetailReport(@AgencyId, '1985-01-01', @initialBalanceFinalDate, @CodeFilter, @CashierId, @UserManagerId))
                , 0)
                - ISNULL((SELECT
                    SUM(CAST(BalanceDetail AS DECIMAL(18, 2)))
                  FROM dbo.FN_GenerateOnyMissingPaymentsDetailReport(@AgencyId, '1985-01-01', @initialBalanceFinalDate, @CodeFilter, @CashierId, @UserManagerId))
                , 0)
                )
              ELSE 0
            END) Debt
           ,NULL UserName
          UNION ALL
          SELECT
            -- 0 DailyAdjustmentId
            AgencyCodeName
           ,-BalanceDetail USD
           ,CAST(Date AS DATE) AS DATE
           ,FORMAT(Date, 'MM-dd-yyyy', 'en-US') CreationDateFormat
           ,NULL AS DatePyament
           ,NULL OtherPaymentId
           ,'MISSING' Description
           ,'MISSING' Details
           ,-BalanceDetail Debt
           ,Employee UserName

          FROM [dbo].FN_GenerateOnyMissingDetailReport(@AgencyId, @StartingDate, @EndingDate, @CodeFilter, @CashierId, @UserManagerId)

          UNION ALL

          SELECT
            -- 0 DailyAdjustmentId
            AgencyCodeName
           ,BalanceDetail USD
           ,CAST(Date AS DATE) AS DATE
           ,FORMAT(Date, 'MM-dd-yyyy', 'en-US') CreationDateFormat
           ,CAST(DatePyament AS DATETIME) AS DatePyament
           ,OtherPaymentId
           ,Type Description
           ,'PAYMENT' Details
           ,BalanceDetail Debt
           ,Employee

          FROM [dbo].FN_GenerateOnyMissingPaymentsDetailReport(@AgencyId, @StartingDate, @EndingDate, @CodeFilter, @CashierId, @UserManagerId)) AS QueryAnindado
        GROUP BY
        --        IndexType
        --                ,DailyAdjustmentId
        --                ,DailyId
        --                ,PaymentId
        AgencyCodeName
       ,Details
       ,UserName
       ,CAST(Date AS Date)
       ,CreationDateFormat
       ,CAST(QueryAnindado.DatePyament AS DATETIME)
       ,OtherPaymentId
       ,Description) AS Query) AS QueryFinal;
  SELECT
    *
   ,(SELECT
        SUM(t2.Debt)
      FROM #TempTableCardPayment t2
      WHERE t2.RowNumber <= t1.RowNumber)
    BalanceFinal
  FROM #TempTableCardPayment t1
  ORDER BY RowNumber ASC;
END;


GO