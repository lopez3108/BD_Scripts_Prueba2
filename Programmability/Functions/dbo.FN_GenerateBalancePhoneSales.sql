SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE   FUNCTION [dbo].[FN_GenerateBalancePhoneSales](@AgencyId   INT,
                                               @FromDate   DATETIME = NULL,
                                               @ToDate     DATETIME = NULL,
                                               @ProviderId INT,
                                               @YearFrom AS   INT,
                                               @MonthFrom AS  INT,
                                               @YearTo AS     INT      = NULL,
                                               @MonthTo AS    INT      = NULL,
                                               @TypeReport AS INT      = NULL) --1 = INITIAL BALANDE 2= ANOTHER
RETURNS @result TABLE
(RowNumberDetail INT,
 AgencyId        INT,
 Date            DATETIME,
 Description     VARCHAR(1000),
 Type            VARCHAR(1000),
 TypeId          INT,
 Usd             DECIMAL(18, 2),
 Cost            DECIMAL(18, 2),
 Credit          DECIMAL(18, 2),
 BalanceDetail   DECIMAL(18, 2),
 UnidadesVendidas  INT,
 Tax             DECIMAL(18, 2),
 Balance         DECIMAL(18, 2)

)
AS
     BEGIN
         DECLARE @TableReturn TABLE
         (RowNumberDetail INT,
          AgencyId        INT,
          Date            DATETIME,
          Description     VARCHAR(1000),
          Type            VARCHAR(1000),
          TypeId          INT,
          Usd             DECIMAL(18, 2),
          Cost            DECIMAL(18, 2),
          Credit          DECIMAL(18, 2),
          BalanceDetail   DECIMAL(18, 2),
		  UnidadesVendidas  INT,
		  Tax             DECIMAL(18, 2)
		  
         );
         INSERT INTO @TableReturn
         (RowNumberDetail,
          AgencyId,
          Date,
          Description,
          Type,
          TypeId,
          Usd,
          Cost,
          Credit,
          BalanceDetail,
		   UnidadesVendidas,
		   Tax
         )
                SELECT *
                FROM
                (
                    SELECT ROW_NUMBER() OVER(ORDER BY Query.TypeId ASC,
                                                      CAST(Query.Date AS DATE) ASC) RowNumberDetail,
                           *
                    FROM
                    (
                        SELECT I.AgencyId,
                               CAST(S.CreationDate AS DATE) AS DATE,
                               'CLOSING DAILY' Description,
                               'PHONE' Type,
                               1 TypeId,
                               SUM(S.SellingValue) AS Usd,
                               SUM(S.PurchaseValue) AS Cost,
                               0 Credit,
                               SUM(S.SellingValue) - SUM(S.PurchaseValue) AS BalanceDetail,
							   count(*) AS UnidadesVendidas,
							   SUM(S.sellingValue * S.tax / 100) AS Tax
							  
                        FROM PhoneSales S
                             INNER JOIN Inventorybyagency I ON I.InventoryByAgencyId = S.InventoryByAgencyId
                             INNER JOIN Agencies A ON A.AgencyId = I.AgencyId
                             INNER JOIN Inventory IV ON I.InventoryId = IV.InventoryId
                             --INNER JOIN PhonePlans P ON P.PhonePlanId = S.PhonePlanId
                        WHERE A.AgencyId = @AgencyId
                              AND (CAST(S.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                                   OR @FromDate IS NULL)
                              AND (CAST(S.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                                   OR @ToDate IS NULL)
                        GROUP BY I.AgencyId,
                                 A.Name,
                                 CAST(S.CreationDate AS DATE)
                        UNION ALL
                        SELECT Agencies.AgencyId,
                               ProviderCommissionPayments.CreationDate DATE,
                                'COMMISSIONS '+dbo.[fn_GetMonthByNum](Month) +'-'+CAST(Year AS CHAR(4)) Description,
                               'COMMISSION' Type,
                               2 TypeId,
                               0 Usd,
                               0 Cost,
                               ISNULL(ProviderCommissionPayments.Usd, 0) Credit,
                               -ISNULL(ProviderCommissionPayments.Usd, 0) BalanceDetail,
							    0 AS  UnidadesVendidas,
								 0 AS Tax 
                        FROM dbo.ProviderCommissionPayments
                             INNER JOIN dbo.Providers ON dbo.ProviderCommissionPayments.ProviderId = dbo.Providers.ProviderId
                             INNER JOIN dbo.ProviderCommissionPaymentTypes ON dbo.ProviderCommissionPayments.ProviderCommissionPaymentTypeId = dbo.ProviderCommissionPaymentTypes.ProviderCommissionPaymentTypeId
                             INNER JOIN dbo.Agencies ON dbo.ProviderCommissionPayments.AgencyId = dbo.Agencies.AgencyId
                             LEFT OUTER JOIN dbo.Bank ON dbo.ProviderCommissionPayments.BankId = dbo.Bank.BankId
                             INNER JOIN dbo.ProviderTypes ON dbo.ProviderTypes.ProviderTypeId = dbo.Providers.ProviderTypeId
                        WHERE ProviderCommissionPayments.AgencyId = @AgencyId
                              AND ((ProviderCommissionPayments.Year = @YearFrom
                                    AND (ProviderCommissionPayments.Month > @MonthFrom
                                         AND @TypeReport = 1
                                         OR ProviderCommissionPayments.Month >= @MonthFrom
                                         AND @TypeReport = 2))
                                   OR (ProviderCommissionPayments.Year > @YearFrom)
                                   OR @YearFrom IS NULL)
                              AND ((ProviderCommissionPayments.Year = @YearTo
                                    AND (ProviderCommissionPayments.Month < @MonthTo
                                         AND @TypeReport = 1
                                         OR ProviderCommissionPayments.Month <= @MonthTo
                                         AND @TypeReport = 2))
                                   OR (ProviderCommissionPayments.Year < @YearTo)
                                   OR @YearTo IS NULL)
                              --AND ProviderCommissionPayments.Year >= 2000
                              --AND ProviderCommissionPayments.Month >= 1
                              AND ProviderCommissionPayments.ProviderId = @ProviderId
                    ) AS Query
                ) AS QueryFinal
                ORDER BY RowNumberDetail DESC;
         INSERT INTO @result
         (RowNumberDetail,
          AgencyId,
          Date,
          Description,
          Type,
          TypeId,
          Usd,
          Cost,
          Credit,
          BalanceDetail,
		  UnidadesVendidas,
		  Tax,
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


         --SELECT *,
         --(
         --    SELECT SUM(t2.BalanceDetail)
         --    FROM @result t2
         --    WHERE T2.RowNumberDetail <= T1.RowNumberDetail
         --) Balance
         --FROM @result t1
         --ORDER BY RowNumberDetail ASC;
         RETURN;
     END;
GO