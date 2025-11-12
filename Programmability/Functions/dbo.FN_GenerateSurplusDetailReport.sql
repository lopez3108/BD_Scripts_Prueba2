SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:24-10-2023
--CAMBIOS EN 5463, cambiar fecha de  pago de comisiones

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:22-09-2023
--CAMBIOS EN 5399, Refactoring reporte de surplus

--Update by JT/02-09-2025 TASK 6689 Daily report nueva columna TOTAL CASH DAILY ADMIN SE LE SUMA EL CASH DISTRIBUTED

CREATE FUNCTION [dbo].[FN_GenerateSurplusDetailReport] (@AgencyId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL)
RETURNS @result TABLE (
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


AS
BEGIN
  DECLARE @YearFrom AS INT
         ,@YearTo AS INT
         ,@MonthFrom AS INT
         ,@MonthTo AS INT
         ,@ProviderId AS INT;

  SET @YearFrom = CAST(YEAR(CAST(@FromDate AS DATE)) AS VARCHAR(10));
  SET @YearTo = CAST(YEAR(CAST(@ToDate AS DATE)) AS VARCHAR(10));
  SET @MonthFrom = CAST(MONTH(CAST(@FromDate AS DATE)) AS VARCHAR(10));
  SET @MonthTo = CAST(MONTH(CAST(@ToDate AS DATE)) AS VARCHAR(10));
  SET @ProviderId = (SELECT TOP 1
      ProviderId
    FROM Providers
    INNER JOIN ProviderTypes
      ON Providers.ProviderTypeId = ProviderTypes.ProviderTypeId
    WHERE ProviderTypes.Code = 'C21');


  INSERT INTO @result
    SELECT
      ROW_NUMBER() OVER (
      ORDER BY Query.TypeId ASC,
      CAST(Query.Date AS Date) ASC,
      UserBeneficaryId ASC,
      Query.Id ASC
      ) [Index]
     ,Query.AgencyId
     ,Query.Date Date
     ,Query.Employee
     ,Query.Type
     ,Query.TypeId
     ,Query.UserBeneficaryId
     ,Query.Usd
     ,Query.Credit
     ,Query.BalanceDetail

    FROM (SELECT
        Id
       ,AgencyId
       ,Date
       ,Employee
       ,Type
       ,TypeId
       ,UserBeneficaryId
       ,Usd
       ,Credit
       ,Usd BalanceDetail
      FROM (SELECT
          1 Id
         ,D.AgencyId
         ,CAST(D.CreationDate AS DATE) AS DATE
         ,U.Name Employee
         ,'DAILY' Type
         ,1 TypeId
         ,C.CashierId UserBeneficaryId
         ,CASE
            WHEN ((((SELECT
                  CASE
                    WHEN D.ClosedByCashAdmin > 0 THEN SUM(ABS(D.CashAdmin))
                      + ISNULL((SELECT
                          SUM(DD.Usd)
                        FROM DailyDistribution DD
                        WHERE D.DailyId = DD.DailyId
                      --    AND DD.DailyDistributionId > 18
                      )
                      , 0)
                    ELSE SUM(ABS(D.Cash))
                  END AS USD)
              + (SELECT
                  CASE
                    WHEN D.CardPaymentsAdmin > 0 THEN SUM(ABS(D.CardPaymentsAdmin))
                    ELSE SUM(ABS(D.CardPayments))
                  END AS USD)
              ) - Total)) > 0 THEN (((SELECT
                  CASE
                    WHEN D.ClosedByCashAdmin > 0 THEN SUM(ABS(D.CashAdmin))
                      + ISNULL((SELECT
                          SUM(DD.Usd)
                        FROM DailyDistribution DD
                        WHERE D.DailyId = DD.DailyId
                      --    AND DD.DailyDistributionId > 18
                      )
                      , 0)
                    ELSE SUM(ABS(D.Cash))
                  END AS USD)
              + (SELECT
                  CASE
                    WHEN D.CardPaymentsAdmin > 0 THEN SUM(ABS(D.CardPaymentsAdmin))
                    ELSE SUM(ABS(D.CardPayments))
                  END AS USD)
              ) - Total)
            ELSE 0
          END AS Usd
         ,0 Credit
         ,0 BalanceDetail
        --SUM(ABS(D.Surplus)) AS BalanceDetail
        FROM Daily D
        INNER JOIN Agencies A
          ON A.AgencyId = D.AgencyId
        INNER JOIN Cashiers C
          ON C.CashierId = D.CashierId
        INNER JOIN Users U
          ON U.UserId = C.UserId
        WHERE A.AgencyId = @AgencyId
        AND CAST(D.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
        AND CAST(D.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
        GROUP BY D.AgencyId
                ,CAST(D.CreationDate AS DATE)
                ,U.Name
                ,D.CashAdmin
                ,D.ClosedByCashAdmin
                ,D.CardPaymentsAdmin
                ,D.Total
                ,D.DailyId
                ,C.CashierId) AS RESULTDAILY
      UNION ALL
      SELECT
        2 Id
       ,S.AgencyId
       ,CAST(S.RefundSurplusDate AS DATE) AS DATE
       ,
        -- U.Name +'-REFUND' + '-' + CAST(CAST(S.CreatedOn AS DATE) AS VARCHAR(30))+' '+   E.Name Employee, 
        U.Name + ' REFUND' + ' ' + CONVERT(VARCHAR(30), (CAST(S.CreatedOn AS DATE)), 110) Employee
       ,'REFUND' Type
       ,1 TypeId
       ,S.RefundCashierId
       ,0 AS Usd
       ,SUM(ABS(S.Usd)) Credit
       ,-SUM(ABS(S.Usd)) AS BalanceDetail
      FROM Expenses S
      INNER JOIN Agencies A
        ON A.AgencyId = S.AgencyId
      INNER JOIN ExpensesType EX
        ON S.ExpenseTypeId = EX.ExpensesTypeId
      INNER JOIN Users U
        ON U.UserId = S.CreatedBy
      -- INNER JOIN Users E ON E.UserId = S.RefundCashierId
      WHERE (EX.Code = 'C14')
      AND (A.AgencyId = @AgencyId)
      AND CAST(S.RefundSurplusDate AS DATE) >= CAST(@FromDate AS DATE)
      AND CAST(S.RefundSurplusDate AS DATE) <= CAST(@ToDate AS DATE)
      GROUP BY S.AgencyId
              ,CAST(S.CreatedOn AS DATE)
              ,CAST(S.RefundSurplusDate AS DATE)
              ,U.Name
              ,S.RefundCashierId
      --E.Name
      UNION ALL
      SELECT
        2 Id
       ,Agencies.AgencyId
       ,
        --                              ProviderCommissionPayments.CreationDate DATE, 
        dbo.[fn_GetNextDayPeriod](Year, month) AS DATE
       ,
        --                              'CLOSING COMMISSIONS ' Employee, 
        'COMM. ' + dbo.[fn_GetMonthByNum](month) + '-' + CAST(Year AS CHAR(4)) Employee
       ,'COMMISSION' Type
       ,2 TypeId
       ,0 UserBeneficaryId
       ,0 Usd
       ,ISNULL(ProviderCommissionPayments.Usd, 0) Credit
       ,-ISNULL(ProviderCommissionPayments.Usd, 0) BalanceDetail
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
      --                             AND ((ProviderCommissionPayments.Year = @YearFrom
      --                                   AND ProviderCommissionPayments.Month >= @MonthFrom)
      --                                  OR (ProviderCommissionPayments.Year > @YearFrom)
      --                                  OR @YearFrom IS NULL)
      --                             AND ((ProviderCommissionPayments.Year = @YearTo
      --                                   AND ProviderCommissionPayments.Month <= @MonthTo)
      --                                  OR (ProviderCommissionPayments.Year < @YearTo)
      --                                  OR @YearTo IS NULL)
      AND (dbo.[fn_GetNextDayPeriod](Year, Month) >= CAST(@FromDate AS DATE)
      OR @FromDate IS NULL)
      AND (dbo.[fn_GetNextDayPeriod](Year, Month) <= CAST(@ToDate AS DATE)
      OR @ToDate IS NULL)
      AND ProviderCommissionPayments.ProviderId = @ProviderId) AS Query



  RETURN;
END;

GO