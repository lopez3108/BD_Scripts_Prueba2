SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE   FUNCTION [dbo].[FN_GenerateBalanceDiscounts](@AgencyId   INT, 
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
 Credit          DECIMAL(18, 2), 
 BalanceDetail   DECIMAL(18, 2), 
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
          Credit          DECIMAL(18, 2), 
          BalanceDetail   DECIMAL(18, 2)
         );
         INSERT INTO @TableReturn
         (RowNumberDetail, 
          AgencyId, 
          Date, 
          Description, 
          Type, 
          TypeId, 
          Usd, 
          Credit, 
          BalanceDetail
         )
                SELECT *
                FROM
                (
                    SELECT ROW_NUMBER() OVER(
                           ORDER BY Query.TypeId ASC, 
                                    CAST(Query.Date AS DATE) ASC) RowNumberDetail, 
                           *
                    FROM
                    (
                        SELECT S.AgencyId, ---MONEY TRANSFER
                               CAST(S.CreationDate AS DATE) AS DATE, 
                               'CLOSING DAILY' Description, 
                               'MONEY TRANSFER' Type, 
                               1 TypeId, 
                               SUM(S.Discount) AS Usd, 
                               0 Credit, 
                               SUM(S.Discount) AS BalanceDetail
                        FROM DiscountMoneyTransfers S
                             INNER JOIN Agencies A ON A.AgencyId = S.AgencyId
                        WHERE A.AgencyId = @AgencyId
                        GROUP BY S.AgencyId, 
                                 CAST(S.CreationDate AS DATE)
                        UNION ALL
                        SELECT C.AgencyId, ---CHECK
                               CAST(C.CreationDate AS DATE) AS DATE, 
                               'CLOSING DAILY' Description, 
                               'CHECKS' Type, 
                               2 TypeId, 
                               SUM(C.Discount) AS Usd, 
                               0 Credit, 
                               SUM(C.Discount) AS BalanceDetail
                        FROM DiscountChecks C
                             INNER JOIN Agencies A ON A.AgencyId = C.AgencyId
                        WHERE A.AgencyId = @AgencyId
                        GROUP BY C.AgencyId, 
                                 CAST(C.CreationDate AS DATE)
                        UNION ALL
                        SELECT P.AgencyId, ---PHONES
                               CAST(P.CreationDate AS DATE) AS DATE, 
                               'CLOSING DAILY' Description, 
                               'PHONES' Type, 
                               3 TypeId, 
                               SUM(P.Discount) AS Usd, 
                               0 Credit, 
                               SUM(P.Discount) AS BalanceDetail
                        FROM DiscountPhones P
                             INNER JOIN Agencies A ON A.AgencyId = P.AgencyId
                        WHERE A.AgencyId = @AgencyId
                        GROUP BY P.AgencyId, 
                                 CAST(P.CreationDate AS DATE)
                        UNION ALL
                        SELECT T.AgencyId, ---TITLES
                               CAST(T.CreationDate AS DATE) AS DATE, 
                               'CLOSING DAILY' Description, 
                               'TITLES AND PLATE' Type, 
                               4 TypeId, 
                               SUM(T.Discount) AS Usd, 
                               0 Credit, 
                               SUM(T.Discount) AS BalanceDetail
                        FROM DiscountTitles T
                             INNER JOIN Agencies A ON A.AgencyId = T.AgencyId
                        WHERE A.AgencyId = @AgencyId
                        GROUP BY T.AgencyId, 
                                 CAST(T.CreationDate AS DATE)
                        UNION ALL
                        SELECT C.AgencyId, ---CITY
                               CAST(C.CreationDate AS DATE) AS DATE, 
                               'CLOSING DAILY' Description, 
                               'CITY STICKER' Type, 
                               5 TypeId, 
                               SUM(C.Usd) AS Usd, 
                               0 Credit, 
                               SUM(C.Usd) AS BalanceDetail
                        FROM DiscountCityStickers C
                             INNER JOIN Agencies A ON A.AgencyId = C.AgencyId
                        WHERE A.AgencyId = @AgencyId
                        GROUP BY C.AgencyId, 
                                 CAST(C.CreationDate AS DATE)
                        UNION ALL
                        SELECT L.AgencyId, ---PLATE
                               CAST(L.CreationDate AS DATE) AS DATE, 
                               'CLOSING DAILY' Description, 
                               'REGISTRATION RENEWALS' Type, 
                               6 TypeId, 
                               SUM(L.Usd) AS Usd, 
                               0 Credit, 
                               SUM(L.Usd) AS BalanceDetail
                        FROM DiscountPlateStickers L
                             INNER JOIN Agencies A ON A.AgencyId = L.AgencyId
                        WHERE A.AgencyId = @AgencyId
                        GROUP BY L.AgencyId, 
                                 CAST(L.CreationDate AS DATE)
                        UNION ALL
                        SELECT Agencies.AgencyId, 
                               ProviderCommissionPayments.CreationDate DATE, 
                               'COMMISSIONS ' + dbo.[fn_GetMonthByNum](Month) + '-' + CAST(Year AS CHAR(4)) Description, 
                               'COMMISSION' Type, 
                               2 TypeId, 
                               0 Usd, 
                               ISNULL(ProviderCommissionPayments.Usd, 0) Credit, 
                               -ISNULL(ProviderCommissionPayments.Usd, 0) BalanceDetail
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
                ORDER BY RowNumberDetail ASC;
         INSERT INTO @result
         (RowNumberDetail, 
          AgencyId, 
          Date, 
          Description, 
          Type, 
          TypeId, 
          Usd, 
          Credit, 
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