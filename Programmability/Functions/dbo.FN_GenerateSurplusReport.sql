SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:24-10-2023
--CAMBIOS EN 5463, cambiar fecha de  pago de comisiones

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:22-09-2023
--CAMBIOS EN 5399, Refactoring reporte de surplus


-- =============================================
-- Author:      JF
-- Create date: 25/06/2024 2:47 p. m.
-- Database:    devtest
-- Description: task 5643 Ajustes reportes con commission automatic
-- =============================================

--Update by JT/02-09-2025 TASK 6689 Daily report nueva columna TOTAL CASH DAILY ADMIN SE LE SUMA EL CASH DISTRIBUTED

CREATE FUNCTION [dbo].[FN_GenerateSurplusReport] (@AgencyId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL)
RETURNS @result TABLE (
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
      CAST(Query.Date AS Date) ASC) [Index]
     ,*
    FROM (SELECT
        AgencyId
       ,Date
       ,Description
       ,Type
       ,TypeId
       ,SUM(Usd) Usd
       ,SUM(Credit) Credit
       ,SUM(Usd) BalanceDetail
      FROM (SELECT
          D.AgencyId
         ,CAST(D.CreationDate AS DATE) AS DATE
         ,'CLOSING DAILY' Description
         ,'DAILY' Type
         ,2 TypeId
         ,CASE
            WHEN ((((SELECT
                  CASE
                    WHEN D.ClosedByCashAdmin > 0 --Task 5371 el cash admin permite 0 como valor
                    THEN SUM(ABS(D.CashAdmin))
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
                    WHEN D.ClosedByCashAdmin > 0 --Task 5371 el cash admin permite 0 como valor
                    THEN SUM(ABS(D.CashAdmin))
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
        FROM Daily D
        INNER JOIN Agencies A
          ON A.AgencyId = D.AgencyId
        WHERE A.AgencyId = @AgencyId
        AND CAST(D.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
        AND CAST(D.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
        GROUP BY D.AgencyId
                ,D.DailyId
                ,CAST(D.CreationDate AS DATE)
                ,D.CashAdmin
                ,D.ClosedByCashAdmin
                ,D.CardPaymentsAdmin
                ,D.Total
                ,D.CashierId) AS RESULTDAILY
      GROUP BY AgencyId
              ,DATE
              ,Description
              ,Type
              ,TypeId
      UNION ALL
      SELECT
        S.AgencyId
       ,CAST(S.RefundSurplusDate AS DATE) AS DATE
       ,'CLOSING DAILY REFUND' + ' ' + CONVERT(VARCHAR(30), (CAST(S.CreatedOn AS DATE)), 110) Description
       ,'REFUND' Type
       ,2 TypeId
       ,0 AS Usd
       ,SUM(ABS(S.Usd)) Credit
       ,-SUM(ABS(S.Usd)) AS BalanceDetail
      FROM Expenses S
      INNER JOIN Agencies A
        ON A.AgencyId = S.AgencyId
      INNER JOIN ExpensesType EX
        ON S.ExpenseTypeId = EX.ExpensesTypeId
      WHERE (EX.Code = 'C14')
      AND (A.AgencyId = @AgencyId)
      AND CAST(S.RefundSurplusDate AS DATE) >= CAST(@FromDate AS DATE)
      AND CAST(S.RefundSurplusDate AS DATE) <= CAST(@ToDate AS DATE)
      GROUP BY S.AgencyId
              ,CAST(S.CreatedOn AS DATE)
              ,CAST(S.RefundSurplusDate AS DATE)
      UNION ALL
      SELECT
        Agencies.AgencyId
        --           ,ProviderCommissionPayments.CreationDate DATE
       ,dbo.[fn_GetNextDayPeriod](Year, Month) AS DATE
        --           ,'COMMISSIONS ' Description
       ,'COMM. ' + dbo.[fn_GetMonthByNum](Month) + '-' + CAST(Year AS CHAR(4)) Description

       ,'COMMISSIONS' Type
       ,1 TypeId
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
      --          AND ((ProviderCommissionPayments.Year = @YearFrom
      --          AND ProviderCommissionPayments.Month >= @MonthFrom)
      --          OR (ProviderCommissionPayments.Year > @YearFrom)
      --          OR @YearFrom IS NULL)
      --          AND ((ProviderCommissionPayments.Year = @YearTo
      --          AND ProviderCommissionPayments.Month <= @MonthTo)
      --          OR (ProviderCommissionPayments.Year < @YearTo)
      --          OR @YearTo IS NULL)
      AND (dbo.[fn_GetNextDayPeriod](Year, Month) >= CAST(@FromDate AS DATE)
      OR @FromDate IS NULL)
      AND (dbo.[fn_GetNextDayPeriod](Year, Month) <= CAST(@ToDate AS DATE)
      OR @ToDate IS NULL)
      AND ProviderCommissionPayments.ProviderId = @ProviderId) AS Query


  RETURN;
END;

GO