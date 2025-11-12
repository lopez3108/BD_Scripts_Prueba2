SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:24-10-2023
--CAMBIOS EN 5463, cambiar fecha de  pago de comisiones
CREATE FUNCTION [dbo].[FN_GenerateBalanceLendify](@AgencyId   INT,
                                                 @FromDate   DATETIME = NULL,
                                                 @ToDate     DATETIME = NULL,
                                                 @ProviderId INT,
                                                 @YearFrom AS   INT,
                                                 @MonthFrom AS  INT,
                                                 @YearTo AS     INT      = NULL,
                                                 @MonthTo AS    INT      = NULL,
                                                 @TypeReport AS INT      = NULL) --1 = INITIAL BALANDE 2= ANOTHER
RETURNS @result TABLE
(RowNumberDetail  INT,
 AgencyId         INT,
 Date             DATETIME,
 Description      VARCHAR(1000),
 Type             VARCHAR(1000),
 TypeId           INT,
 Usd              DECIMAL(18, 2),
 Approved         INT,
 CreditCommission DECIMAL(18, 2),
 BalanceDetail    DECIMAL(18, 2),
 Balance          DECIMAL(18, 2)
)
AS
     BEGIN
         DECLARE @TableReturn TABLE
         (RowNumberDetail  INT,
          AgencyId         INT,
          Date             DATETIME,
          Description      VARCHAR(1000),
          Type             VARCHAR(1000),
          TypeId           INT,
          Usd              DECIMAL(18, 2),
          Approved         INT,
          CreditCommission DECIMAL(18, 2),
          BalanceDetail    DECIMAL(18, 2)
         );
         INSERT INTO @TableReturn
         (RowNumberDetail,
          AgencyId,
          Date,
          Description,
          Type,
          TypeId,
          Usd,
          Approved,
          CreditCommission,
          BalanceDetail
         )
                SELECT *
                FROM
                (
                    SELECT ROW_NUMBER() OVER(ORDER BY Query.TypeId ASC,
                                                      CAST(Query.Date AS DATE) ASC) RowNumberDetail,
                           *
                    FROM
                    (
                        SELECT l.AgencyId,
                               CAST(l.AprovedDate AS DATE) AS DATE,
                               'CLOSING DAILY' Description,
                               'APPROVED' Type,
                               1 TypeId,
                               ISNULL(SUM(l.CommissionAgency), 0) AS Usd,
                               COUNT(*) AS Approved,
                               0 CreditCommission,
                               ISNULL(SUM(l.CommissionAgency), 0) AS BalanceDetail
                        FROM Lendify l
                             INNER JOIN Agencies A ON A.AgencyId = l.AgencyId
                             --INNER JOIN PhonePlans P ON P.PhonePlanId = S.PhonePlanId
                        WHERE l.AprovedBy IS NOT NULL
                              AND l.AprovedBy > 0
                              AND A.AgencyId = @AgencyId
                              AND (CAST(l.AprovedDate AS DATE) >= CAST(@FromDate AS DATE)
                                   OR @FromDate IS NULL)
                              AND (CAST(l.AprovedDate AS DATE) <= CAST(@ToDate AS DATE)
                                   OR @ToDate IS NULL)
                        GROUP BY l.AgencyId,
                                 A.Name,
                                 CAST(l.AprovedDate AS DATE)
                        UNION ALL
                        SELECT Agencies.AgencyId,
                         dbo.[fn_GetNextDayPeriod](Year, Month) DATE,
--                               ProviderCommissionPayments.CreationDate DATE,
--                               'COMMISSIONS '+dbo.[fn_GetMonthByNum](Month)+'-'+CAST(Year AS CHAR(4)) Description,
   'COMM. ' + dbo.[fn_GetMonthByNum](Month) + '-' + CAST(Year AS CHAR(4)) Description,
                               'COMMISSIONS' Type,
                               2 TypeId,
                               0 Usd,
                               0 Approved,
                               0 CreditCommission,
                               ISNULL(-ProviderCommissionPayments.Usd, 0) BalanceDetail
                        FROM dbo.ProviderCommissionPayments
                             INNER JOIN dbo.Providers ON dbo.ProviderCommissionPayments.ProviderId = dbo.Providers.ProviderId
                             INNER JOIN dbo.ProviderCommissionPaymentTypes ON dbo.ProviderCommissionPayments.ProviderCommissionPaymentTypeId = dbo.ProviderCommissionPaymentTypes.ProviderCommissionPaymentTypeId
                             INNER JOIN dbo.Agencies ON dbo.ProviderCommissionPayments.AgencyId = dbo.Agencies.AgencyId
                             LEFT OUTER JOIN dbo.Bank ON dbo.ProviderCommissionPayments.BankId = dbo.Bank.BankId
                             INNER JOIN dbo.ProviderTypes ON dbo.ProviderTypes.ProviderTypeId = dbo.Providers.ProviderTypeId
                        WHERE ProviderCommissionPayments.AgencyId = @AgencyId
--                              AND ((ProviderCommissionPayments.Year = @YearFrom
--                                    AND (ProviderCommissionPayments.Month > @MonthFrom
--                                         AND @TypeReport = 1
--                                         OR ProviderCommissionPayments.Month >= @MonthFrom
--                                         AND @TypeReport = 2))
--                                   OR (ProviderCommissionPayments.Year > @YearFrom)
--                                   OR @YearFrom IS NULL)
--                              AND ((ProviderCommissionPayments.Year = @YearTo
--                                    AND (ProviderCommissionPayments.Month < @MonthTo
--                                         AND @TypeReport = 1
--                                         OR ProviderCommissionPayments.Month <= @MonthTo
--                                         AND @TypeReport = 2))
--                                   OR (ProviderCommissionPayments.Year < @YearTo)
--                                   OR @YearTo IS NULL)
 AND (dbo.[fn_GetNextDayPeriod](Year, Month) >= CAST(@FromDate AS DATE)
                      OR @FromDate IS NULL)
                      AND (dbo.[fn_GetNextDayPeriod](Year, Month) <= CAST(@ToDate AS DATE)
                      OR @ToDate IS NULL)        
                              --AND ProviderCommissionPayments.Year >= 2000
                              --AND ProviderCommissionPayments.Month >= 1
                              AND ProviderCommissionPayments.ProviderId = @ProviderId
                    ) AS Query
                ) AS QueryFinal
                ORDER BY RowNumberDetail ASC;
         INSERT INTO @result
         (RowNumberDetail,
          AgencyId,
          Date,
          Description,
          Type,
          TypeId,
          Usd,
          Approved,
          CreditCommission,
          BalanceDetail,
          Balance
         )
         (
             SELECT *,
             (
                 SELECT SUM(t2.BalanceDetail)
                 FROM @TableReturn t2
                 WHERE T2.RowNumberDetail <= T1.RowNumberDetail
             ) Balance
             FROM @TableReturn t1
         );
         RETURN;
     END;
	 

GO