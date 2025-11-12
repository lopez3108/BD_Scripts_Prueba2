SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2025-01-11 DJ/6253: Nuevo reporte insurances commissions
-- 2025-02-06 DJ/6330: Contrapartida reporte INSURANCE COMMISSIONS
-- 2025-02-06 JT/6382: Reporte - Valores de la columna BALANCE no son correctos en el tab INSURANCE COMMISIONS
-- 2025-04-16 JT/6456: Los pagos se deben reflejar justo debajo de la venta
CREATE PROCEDURE [dbo].[sp_GetInsuranceCommissionsReport] (@AgencyId INT,
@ProviderId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL,
@Date DATETIME,
@InsuranceTypeIds VARCHAR(100) = NULL)
AS
BEGIN
  IF (@FromDate IS NULL)
  BEGIN
SET @FromDate = DATEADD(DAY, -10, @Date);
SET @ToDate = @Date;
  END;

DECLARE @initialBalanceFinalDate DATETIME;
SET @initialBalanceFinalDate = DATEADD(DAY, -1, @FromDate);

  DECLARE @agencyInitialBalance DECIMAL(18, 2);
SET @agencyInitialBalance = ISNULL((SELECT
    SUM(CAST(BalanceDetail AS DECIMAL(18, 2)))
  FROM dbo.FN_GenerateInsuranceReport(@AgencyId, @ProviderId, '1985-01-01', @initialBalanceFinalDate, @InsuranceTypeIds))
, 0);

  IF OBJECT_ID('tempdb..#Temp') IS NOT NULL
DROP TABLE #Temp;

CREATE TABLE #Temp (
  [Index] INT
 ,[Group] INT
 ,[Date] DATETIME
 ,[Type] VARCHAR(40)
 ,[Description] VARCHAR(70)
 ,[Transactions] INT
 ,FeeService DECIMAL(18, 2)
 ,Commissionprovider DECIMAL(18, 2) NULL
 ,Credit DECIMAL(18, 2)
 ,BalanceDetail DECIMAL(18, 2)
);

IF OBJECT_ID('tempdb..#TempFinal') IS NOT NULL
DROP TABLE #TempFinal;

CREATE TABLE #TempFinal (
  RowNumber INT
 ,[Index] INT
 ,[Group] INT
 ,[Date] DATETIME
 ,[Type] VARCHAR(40)
 ,[Description] VARCHAR(70)
 ,[Transactions] INT
 ,FeeService DECIMAL(18, 2)
 ,Commissionprovider DECIMAL(18, 2) NULL
 ,Credit DECIMAL(18, 2)
 ,BalanceDetail DECIMAL(18, 2)
);

---- Initial balance
INSERT INTO #Temp ([Index], [Group], [Date], [Type], [Description], [Transactions], FeeService, Commissionprovider, Credit, BalanceDetail)
  SELECT
    0
   ,0
   ,CAST(@initialBalanceFinalDate AS DATE)
   ,'INITIAL BALANCE'
   ,'INITIAL BALANCE'
   ,'-'
   ,0
   ,0
   ,0
   ,@agencyInitialBalance
  UNION ALL
  SELECT
    q.[Index]
   ,q.[Group]
   ,CAST(q.Date AS DATE)
   ,q.[Type]
   ,q.[Description]
   ,CASE
      WHEN q.[Index] = 6 THEN (SELECT
            i.NewPolicyQuantity + i.MonthlyPaymentQuantity + i.EndorsementQuantity + i.PolicyRenewalQuantity + i.RegistrationReleaseQuantity
          FROM dbo.InsuranceProviderCommissionPayment i
          WHERE i.ProviderCommissionPaymentId = q.InsuranceId)
      ELSE COUNT(*)
    END
   ,SUM(q.FeeService)
   ,CASE
      WHEN q.[Index] = 6 AND
        CounterPartIndex = 1 THEN (SELECT
            i.NewPolicyAmount + i.MonthlyPaymentAmount + i.EndorsementAmount + i.PolicyRenewalAmount + i.RegistrationReleaseAmount
          FROM dbo.InsuranceProviderCommissionPayment i
          WHERE i.ProviderCommissionPaymentId = q.InsuranceId)
        + SUM(q.CommissionProvider)
      ELSE SUM(q.CommissionProvider)
    END
   ,CASE
      WHEN q.[Index] = 6 AND
        CounterPartIndex = 2 THEN (SELECT
            i.NewPolicyAmount + i.MonthlyPaymentAmount + i.EndorsementAmount + i.PolicyRenewalAmount + i.RegistrationReleaseAmount
          FROM dbo.InsuranceProviderCommissionPayment i
          WHERE i.ProviderCommissionPaymentId = q.InsuranceId)
        + SUM(q.Credit)
      ELSE SUM(q.Credit)
    END
   ,CASE
      WHEN q.[Index] = 6 AND
        q.CounterPartIndex = 1 THEN (SELECT
            i.NewPolicyAmount + i.MonthlyPaymentAmount + i.EndorsementAmount + i.PolicyRenewalAmount + i.RegistrationReleaseAmount
          FROM dbo.InsuranceProviderCommissionPayment i
          WHERE i.ProviderCommissionPaymentId = q.InsuranceId)
        + SUM(q.CommissionProvider)
      WHEN q.[Index] = 6 AND
        CounterPartIndex = 2 THEN (((SELECT
            i.NewPolicyAmount + i.MonthlyPaymentAmount + i.EndorsementAmount + i.PolicyRenewalAmount + i.RegistrationReleaseAmount
          FROM dbo.InsuranceProviderCommissionPayment i
          WHERE i.ProviderCommissionPaymentId = q.InsuranceId)
        + SUM(q.Credit)) * -1)
      ELSE SUM(q.BalanceDetail)
    END
  FROM dbo.FN_GetInsuranceCommissions(@AgencyId, @ProviderId, @FromDate, @ToDate, @InsuranceTypeIds) q
  GROUP BY q.[Index]
          ,q.[Group]
          ,CAST(q.Date AS DATE)
          ,q.Type
          ,q.Description
          ,q.CounterPartIndex
          ,q.InsuranceId;

-- Corregido: Evitamos insertar en la columna ID de #TempFinal
INSERT INTO #TempFinal (RowNumber, [Index], [Group], [Date], [Type], [Description], [Transactions], FeeService, Commissionprovider, Credit, BalanceDetail)
  SELECT
    ROW_NUMBER() OVER (ORDER BY CAST(Date AS DATE) ASC, [Index] ASC, [Group] ASC) AS RowNumber
   ,[Index]
   ,[Group]
   ,CAST(Date AS DATE)
   ,[Type]
   ,[Description]
   ,SUM([Transactions]) AS Transactions
   ,SUM(FeeService) AS FeeService
   ,SUM(Commissionprovider) AS Commissionprovider
   ,SUM(Credit) AS Credit
   ,SUM(BalanceDetail) AS BalanceDetail
  FROM #Temp
  GROUP BY [Index]
          ,[Group]
          ,CAST(Date AS DATE)
          ,[Type]
          ,[Description];


-- Resultados finales con la columna RunningSum
SELECT
  *
 ,(SELECT
      ISNULL(SUM(CAST(BalanceDetail AS DECIMAL(18, 2))), 0)
    FROM #TempFinal T2
    WHERE T2.RowNumber <= T1.RowNumber)
  AS RunningSum
FROM #TempFinal T1
ORDER BY RowNumber ASC;

DROP TABLE #Temp;
DROP TABLE #TempFinal;
END;

GO