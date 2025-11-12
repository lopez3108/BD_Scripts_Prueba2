SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Update by jt/14-07-2024 Task 5885 order by commission in first position
CREATE FUNCTION [dbo].[FN_GenerateBalanceTrp] (@AgencyId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL,
@ProviderId INT,
@YearFrom AS INT,
@MonthFrom AS INT,
@YearTo AS INT = NULL,
@MonthTo AS INT = NULL,
@TypeReport AS INT = NULL) --1 = INITIAL BALANDE 2= ANOTHER
RETURNS @result TABLE (
  RowNumberDetail INT
 ,AgencyId INT
 ,Date DATETIME
 ,Description VARCHAR(1000)
 ,Type VARCHAR(1000)
 ,TypeId INT
 ,Transactions INT
 ,Usd DECIMAL(18, 2)
 ,FeeService DECIMAL(18, 2)
 ,TrpFee DECIMAL(18, 2)
 ,TrpCreditCost DECIMAL(18, 2)
 ,Credit DECIMAL(18, 2)
 ,BalanceCostDetail DECIMAL(18, 2)
 ,BalanceCommissionDetail DECIMAL(18, 2)
 ,BalanceCost DECIMAL(18, 2)
 ,BalanceCommission DECIMAL(18, 2)
)
AS
BEGIN
  DECLARE @TableReturn TABLE (
    RowNumberDetail INT
   ,AgencyId INT
   ,Date DATETIME
   ,Description VARCHAR(1000)
   ,Type VARCHAR(1000)
   ,TypeId INT
   ,Transactions INT
   ,Usd DECIMAL(18, 2)
   ,FeeService DECIMAL(18, 2)
   ,TrpFee DECIMAL(18, 2)
   ,TrpCreditCost DECIMAL(18, 2)
   ,Credit DECIMAL(18, 2)
   ,BalanceCostDetail DECIMAL(18, 2)
   ,BalanceCommissionDetail DECIMAL(18, 2)
  );
  INSERT INTO @TableReturn (RowNumberDetail,
  AgencyId,
  Date,
  Description,
  Type,
  TypeId,
  Transactions,
  Usd,
  FeeService,
  TrpFee,
  TrpCreditCost,
  Credit,
  BalanceCostDetail,
  BalanceCommissionDetail)
    SELECT
      *
    FROM (SELECT
        ROW_NUMBER() OVER (ORDER BY Query.TypeId ASC,
        CAST(Query.Date AS Date) ASC) RowNumberDetail
       ,*
      FROM (SELECT
          S.AgencyId
         ,CAST(S.CreatedOn AS DATE) AS DATE
         ,'CLOSING DAILY' Description
         ,'TRP' Type
         ,1 TypeId
         ,COUNT(*) AS Transactions
         ,SUM(S.Usd) AS Usd
         ,SUM(ISNULL(S.Fee1, 0)) AS FeeService
         ,SUM(ISNULL(S.TrpFee, 0)) AS TrpFee
         ,0 TrpCreditCost
         ,0 Credit
         ,SUM(ISNULL(S.TrpFee, 0)) BalanceCostDetail
         ,(SUM(S.Usd) + SUM(ISNULL(S.Fee1, 0))) - SUM(ISNULL(S.TrpFee, 0)) AS BalanceCommissionDetail
        FROM TRP S
        INNER JOIN Agencies A
          ON A.AgencyId = S.AgencyId
        --INNER JOIN PhonePlans P ON P.PhonePlanId = S.PhonePlanId
        WHERE A.AgencyId = @AgencyId
        AND (CAST(S.CreatedOn AS DATE) >= CAST(@FromDate AS DATE)
        OR @FromDate IS NULL)
        AND (CAST(S.CreatedOn AS DATE) <= CAST(@ToDate AS DATE)
        OR @ToDate IS NULL)
        GROUP BY S.AgencyId
                ,A.Name
                ,CAST(S.CreatedOn AS DATE)
        UNION ALL
        SELECT
          S.AgencyId
         ,CAST(S.CreatedOn AS DATE) AS DATE
         ,'CLOSING DAILY' Description
         ,'LAMINATION' Type
         ,2 TypeId
         ,COUNT(*) AS Transactions
         ,SUM(ISNULL(S.LaminationFee, 0)) AS Usd
         ,0 AS FeeService
         ,0 AS TrpFee
         ,0 TrpCreditCost
         ,0 Credit
         ,0 BalanceCostDetail
         ,SUM(ISNULL(S.LaminationFee, 0)) AS BalanceCommissionDetail
        FROM TRP S
        INNER JOIN Agencies A
          ON A.AgencyId = S.AgencyId
        --INNER JOIN PhonePlans P ON P.PhonePlanId = S.PhonePlanId
        WHERE S.LaminationFee > 0
        AND A.AgencyId = @AgencyId
        AND (CAST(S.CreatedOn AS DATE) >= CAST(@FromDate AS DATE)
        OR @FromDate IS NULL)
        AND (CAST(S.CreatedOn AS DATE) <= CAST(@ToDate AS DATE)
        OR @ToDate IS NULL)
        GROUP BY S.AgencyId
                ,A.Name
                ,CAST(S.CreatedOn AS DATE)
        UNION ALL
        SELECT
          S.AgencyId
         ,CAST(S.PaymentDate AS DATE) AS DATE
         ,'CLOSING DAILY' Description
         ,'TRP CREDIT-COST' Type
         ,3 TypeId
         ,COUNT(*) AS Transactions
         ,0 AS Usd
         ,0 AS FeeService
         ,0 AS TrpFee
         ,SUM(S.TrpFee)  TrpCreditCost
         ,0 Credit
         ,-SUM(S.TrpFee) BalanceCostDetail
         ,0 AS BalanceCommissionDetail
        FROM TRP S
        INNER JOIN Agencies A
          ON A.AgencyId = S.AgencyId
        --INNER JOIN PhonePlans P ON P.PhonePlanId = S.PhonePlanId
        WHERE A.AgencyId = @AgencyId
        AND (CAST(S.PaymentDate AS DATE) >= CAST(@FromDate AS DATE)
        OR @FromDate IS NULL)
        AND (CAST(S.PaymentDate AS DATE) <= CAST(@ToDate AS DATE)
        OR @ToDate IS NULL)
		AND PaidBy > 0
        GROUP BY S.AgencyId
                ,A.Name
                ,CAST(S.PaymentDate AS DATE)
        UNION ALL
       --SELECT * FROM (
	   SELECT
          Agencies.AgencyId
         --,CAST(ProviderCommissionPayments.CreationDate AS DATE) DATE
		 --Task 5401 El pago de esta comisión, independientemente de la fecha en que se pague, en el reporte de TRP, debe salir con la fecha del primer día del mes después al periodo pagado, como se explica en la siguiente imagen:
		 ,dbo.[fn_GetNextDayPeriod](Year, Month) DATE
         ,'COMM. ' + dbo.[fn_GetMonthByNum](Month) + '-' + CAST(Year AS CHAR(4)) Description
         ,'COMMISSION' Type
         ,0 TypeId --Update by jt/14-07-2024 Task 5885 order by commission in first position
         ,ProviderCommissionPayments.TotalTransactions Transactions
         ,0 Usd
         ,0 FeeService
         ,0 TrpFee
         ,0 TrpCreditCost
         ,ISNULL(ProviderCommissionPayments.Usd, 0) Credit
         ,0 BalanceCostDetail
         ,-ISNULL(ProviderCommissionPayments.Usd, 0) BalanceCommissionDetail
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
        --Task 5401 El pago de esta comisión, independientemente de la fecha en que se pague, en el reporte de TRP, debe salir con la fecha del primer día del mes después al periodo pagado, como se explica en la siguiente imagen:
		 AND (dbo.[fn_GetNextDayPeriod](Year, Month) >= CAST(@FromDate AS DATE)
        OR @FromDate IS NULL)
        AND (dbo.[fn_GetNextDayPeriod](Year, Month) <= CAST(@ToDate AS DATE)
        OR @ToDate IS NULL)
		--AND ((ProviderCommissionPayments.Year = @YearFrom
  --      AND (ProviderCommissionPayments.Month > @MonthFrom
  --      AND @TypeReport = 1
  --      OR ProviderCommissionPayments.Month >= @MonthFrom
  --      AND @TypeReport = 2))
  --      OR (ProviderCommissionPayments.Year > @YearFrom)
  --      OR @YearFrom IS NULL)
  --      AND ((ProviderCommissionPayments.Year = @YearTo
  --      AND (ProviderCommissionPayments.Month < @MonthTo
  --      AND @TypeReport = 1
  --      OR ProviderCommissionPayments.Month <= @MonthTo
  --      AND @TypeReport = 2))
  --      OR (ProviderCommissionPayments.Year < @YearTo)
  --      OR @YearTo IS NULL)
  --      AND ProviderCommissionPayments.Year >= 2000
  --      AND ProviderCommissionPayments.Month >= 1
        AND ProviderCommissionPayments.ProviderId = @ProviderId)
		AS Query) AS QueryFinal
    ORDER BY RowNumberDetail ASC;
  INSERT INTO @result (RowNumberDetail,
  AgencyId,
  Date,
  Description,
  Type,
  TypeId,
  Transactions,
  Usd,
  FeeService,
  TrpFee,
  TrpCreditCost,
  Credit,
  BalanceCostDetail,
  BalanceCommissionDetail,
  BalanceCost,
  BalanceCommission)
    (
    SELECT
      *
     ,(SELECT
          SUM(t2.BalanceCostDetail)
        FROM @TableReturn t2
        WHERE t2.RowNumberDetail <= t1.RowNumberDetail)
      BalanceCost
     ,(SELECT
          SUM(t2.BalanceCommissionDetail)
        FROM @TableReturn t2
        WHERE t2.RowNumberDetail <= t1.RowNumberDetail)
      BalanceCommission
    FROM @TableReturn t1
    );
  RETURN;
END;
GO