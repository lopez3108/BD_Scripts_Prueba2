SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE   FUNCTION [dbo].[FN_GetComissionsCardPayments](@FromDate        DATETIME = NULL, 
                                                    @ToDate          DATETIME = NULL, 
                                                    @Date            DATETIME = NULL, 
                                                    @Month           INT      = NULL, 
                                                    @Year            INT      = NULL, 
                                                    @AgencyId        INT, 
                                                    @FromCommissions INT)
RETURNS @result TABLE
(RowNumber     INT, 
 AgencyId      INT, 
 Date          DATETIME, 
 Description   VARCHAR(1000), 
 Type          VARCHAR(1000), 
 Transactions  INT, 
 TypeId        INT, 
 Usd           DECIMAL(18, 2), 
 FeeService    DECIMAL(18, 2), 
 Credit        DECIMAL(18, 2), 
 BalanceDetail DECIMAL(18, 2)
)
AS
     BEGIN
         DECLARE @YearFrom AS INT, @YearTo AS INT, @MonthFrom AS INT, @MonthTo AS INT, @ProviderId AS INT, @FromDateInitial AS DATETIME;
         IF(@FromCommissions = 0)
             BEGIN
                 IF(@FromDate IS NULL)
                     BEGIN
                         SET @FromDate = DATEADD(day, -10, @Date);
                         SET @ToDate = @Date;
                     END;
                 SET @FromDateInitial = DATEADD(day, -1, @FromDate);
                 SET @YearFrom = CAST(YEAR(CAST(@FromDate AS DATE)) AS VARCHAR(10));
                 SET @YearTo = CAST(YEAR(CAST(@ToDate AS DATE)) AS VARCHAR(10));
                 SET @MonthFrom = CAST(MONTH(CAST(@FromDate AS DATE)) AS VARCHAR(10));
                 SET @MonthTo = CAST(MONTH(CAST(@ToDate AS DATE)) AS VARCHAR(10));
                 SET @ProviderId =
                 (
                     SELECT TOP 1 ProviderId
                     FROM Providers
                          INNER JOIN ProviderTypes ON Providers.ProviderTypeId = ProviderTypes.ProviderTypeId
                     WHERE ProviderTypes.Code = 'C25'
                 );
             END;
         INSERT INTO @result
                SELECT DENSE_RANK() OVER(
                       ORDER BY CAST(Date AS DATE) , TypeId 
                                 ASC) RowNumber, 
                       AgencyId, 
                       Date, 
                       Description, 
                       Type, 
                       SUM(Transactions) Transactions, 
                       TypeId, 
                       SUM(Usd), 
                       SUM(FeeService), 
                       SUM(Credit), 
                       SUM(BalanceDetail)
                FROM
                (
                    --DepositFinancingPayments
                    SELECT DP.AgencyId, 
                           CAST(DP.CreationDate AS DATE) AS DATE, 
                           'CLOSING DAILY' Description, 
                           'CARD PAYMENT FEE' Type, 
                           COUNT(*) AS Transactions, 
                           1 TypeId, 
                           SUM(ISNULL(DP.Usd, 0)) + SUM(ISNULL(DP.CardPaymentFee, 0)) AS Usd, 
                           SUM(ISNULL(DP.CardPaymentFee, 0)) AS FeeService, 
                           0 Credit, 
                           SUM(ISNULL(DP.CardPaymentFee, 0)) AS BalanceDetail
                    FROM DepositFinancingPayments DP
                         INNER JOIN Agencies A ON A.AgencyId = DP.AgencyId
                    WHERE A.AgencyId = @AgencyId
                          AND DP.CardPayment = 1
                          AND (@FromCommissions = 1
                               AND (CAST(DATEPART(month, CreationDate) AS INT) = @Month
                                    AND CAST(DATEPART(year, CreationDate) AS INT) = @Year)
                               OR @FromCommissions = 0
                               AND (CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                                    AND CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)))
                    GROUP BY DP.AgencyId, 
                             CAST(DP.CreationDate AS DATE)
                    UNION ALL--RentPayments
                    SELECT RN.AgencyId, 
                           CAST(RN.CreationDate AS DATE) AS DATE, 
                           'CLOSING DAILY' Description, 
                           'CARD PAYMENT FEE' Type, 
                           COUNT(*) AS Transactions, 
                           1 TypeId,                            
                           SUM(ISNULL(RN.Usd, 0)) + SUM(ISNULL(RN.CardPaymentFee, 0)) + SUM(ISNULL(RN.FeeDue, 0)) AS Usd, 
                           SUM(ISNULL(RN.CardPaymentFee, 0)) AS FeeService, 
                           0 Credit, 
                           --SUM(ISNULL(RN.CardPaymentFee, 0)) + SUM(ISNULL(RN.FeeDue, 0)) AS BalanceDetail
                           SUM(ISNULL(RN.CardPaymentFee, 0)) AS BalanceDetail
                    FROM RentPayments RN
                         INNER JOIN Agencies A ON A.AgencyId = RN.AgencyId
                    WHERE A.AgencyId = @AgencyId
                          AND RN.CardPayment = 1
                          AND (@FromCommissions = 1
                               AND (CAST(DATEPART(month, CreationDate) AS INT) = @Month
                                    AND CAST(DATEPART(year, CreationDate) AS INT) = @Year)
                               OR @FromCommissions = 0
                               AND (CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                                    AND CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)))
                    GROUP BY RN.AgencyId, 
                             CAST(RN.CreationDate AS DATE)
                    UNION ALL--ProvisionalReceipts
                    SELECT PR.AgencyId, 
                           CAST(PR.CreationDate AS DATE) AS DATE, 
                           'CLOSING DAILY' Description, 
                           'CARD PAYMENT FEE' Type, 
                           COUNT(*) AS Transactions, 
                           1 TypeId, 
                           SUM(ISNULL(PR.Total, 0)) + SUM(ISNULL(PR.CardPaymentFee, 0)) + SUM(ISNULL(PR.OtherFees, 0)) AS Usd, 
                           --SUM(ISNULL(PR.OtherFees, 0)) + SUM(ISNULL(PR.CardPaymentFee, 0)) AS FeeService, 
                           SUM(ISNULL(PR.CardPaymentFee, 0)) AS FeeService, 
                           0 Credit, 
                           --SUM(ISNULL(PR.OtherFees, 0)) + SUM(ISNULL(PR.CardPaymentFee, 0)) AS BalanceDetail
                           SUM(ISNULL(PR.CardPaymentFee, 0)) AS BalanceDetail
                    FROM ProvisionalReceipts PR
                         INNER JOIN Agencies A ON A.AgencyId = PR.AgencyId
                    WHERE A.AgencyId = @AgencyId
                          AND PR.CardPayment = 1
                          AND (@FromCommissions = 1
                               AND (CAST(DATEPART(month, CreationDate) AS INT) = @Month
                                    AND CAST(DATEPART(year, CreationDate) AS INT) = @Year)
                               OR @FromCommissions = 0
                               AND (CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                                    AND CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)))
                    GROUP BY PR.AgencyId, 
                             CAST(PR.CreationDate AS DATE)
                    UNION ALL --ReturnPayments
                    SELECT A.AgencyId, 
                           CAST(P.CreationDate AS DATE) AS DATE, 
                           'CLOSING DAILY' Description, 
                           'CARD PAYMENT FEE' Type, 
                           COUNT(*) AS Transactions, 
                           1 TypeId, 
                           SUM(ISNULL(P.Usd, 0)) + SUM(ISNULL(P.CardPaymentFee, 0)) AS Usd, 
                           SUM(ISNULL(P.CardPaymentFee, 0)) AS FeeService, 
                           0 Credit, 
                           SUM(ISNULL(P.CardPaymentFee, 0)) AS BalanceDetail
                    FROM ReturnedCheck RC
                         INNER JOIN ReturnPayments P ON P.ReturnedCheckId = RC.ReturnedCheckId
                         INNER JOIN Agencies A ON A.AgencyId = P.AgencyId
                    WHERE A.AgencyId = @AgencyId
                          AND P.CardPayment = 1
                          AND (@FromCommissions = 1
                               AND (CAST(DATEPART(month, P.CreationDate) AS INT) = @Month
                                    AND CAST(DATEPART(year, P.CreationDate) AS INT) = @Year)
                               OR @FromCommissions = 0
                               AND (CAST(P.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                                    AND CAST(P.CreationDate AS DATE) <= CAST(@ToDate AS DATE)))
                    GROUP BY A.AgencyId, 
                             CAST(P.CreationDate AS DATE)
                    UNION ALL --CountryTaxes
                    SELECT T.AgencyId, 
                           CAST(T.CreationDate AS DATE) AS DATE, 
                           'CLOSING DAILY' Description, 
                           'CARD PAYMENT FEE' Type, 
                           COUNT(*) AS Transactions, 
                           1 TypeId, 
                           SUM(ISNULL(T.Usd, 0)) + SUM(ISNULL(T.CardPaymentFee, 0)) + SUM(ISNULL(T.Fee1, 0)) AS Usd, 
                           --SUM(ISNULL(T.Fee1, 0)) + SUM(ISNULL(T.CardPaymentFee, 0)) AS FeeService, 
                           SUM(ISNULL(T.CardPaymentFee, 0)) AS FeeService, 
                           0 Credit, 
                           --SUM(ISNULL(T.Fee1, 0)) + SUM(ISNULL(T.CardPaymentFee, 0)) AS BalanceDetail
                           SUM(ISNULL(T.CardPaymentFee, 0)) AS BalanceDetail
                    FROM CountryTaxes T
                         INNER JOIN Agencies A ON A.AgencyId = T.AgencyId
                    WHERE A.AgencyId = @AgencyId
                          AND T.cardpayment = 1
                          AND (@FromCommissions = 1
                               AND (CAST(DATEPART(month, CreationDate) AS INT) = @Month
                                    AND CAST(DATEPART(year, CreationDate) AS INT) = @Year)
                               OR @FromCommissions = 0
                               AND (CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                                    AND CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)))
                    GROUP BY T.AgencyId, 
                             CAST(T.CreationDate AS DATE)
                    UNION ALL --PromotionalCodes CityStickers
                    SELECT C.AgencyId, 
                           CAST(C.CreationDate AS DATE) AS DATE, 
                           'CLOSING DAILY' Description, 
                           'CARD PAYMENT FEE' Type, 
                           COUNT(*) AS Transactions, 
                           1 TypeId, 
                           SUM(ISNULL(C.Usd, 0)) + SUM(ISNULL(C.CardPaymentFee, 0)) + SUM(ISNULL(C.Fee1, 0)) - SUM(ISNULL(PC.Usd, 0)) AS Usd, 
                           SUM(ISNULL(C.CardPaymentFee, 0)) AS FeeService, 
                           0 Credit, 
                           --SUM(ISNULL(C.CardPaymentFee, 0)) + SUM(ISNULL(C.Fee1, 0)) - SUM(ISNULL(PC.Usd, 0)) AS BalanceDetail
                           SUM(ISNULL(C.CardPaymentFee, 0)) AS BalanceDetail
                    FROM dbo.PromotionalCodes AS PC
                         INNER JOIN dbo.PromotionalCodesStatus AS PS ON PC.PromotionalCodeId = PS.PromotionalCodeId
                         RIGHT OUTER JOIN dbo.CityStickers AS C
                         INNER JOIN dbo.Agencies AS A ON A.AgencyId = C.AgencyId ON PS.CityStickerId = C.CityStickerId
                    WHERE A.AgencyId = @AgencyId
                          AND C.cardpayment = 1
                          AND (@FromCommissions = 1
                               AND (CAST(DATEPART(month, C.CreationDate) AS INT) = @Month
                                    AND CAST(DATEPART(year, C.CreationDate) AS INT) = @Year)
                               OR @FromCommissions = 0
                               AND (CAST(C.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                                    AND CAST(C.CreationDate AS DATE) <= CAST(@ToDate AS DATE)))
                    GROUP BY C.AgencyId, 
                             CAST(C.CreationDate AS DATE)
                    UNION ALL --PromotionalCodes PlateStickers
                    SELECT PL.AgencyId, 
                           CAST(PL.CreationDate AS DATE) AS DATE, 
                           'CLOSING DAILY' Description, 
                           'CARD PAYMENT FEE' Type, 
                           COUNT(*) AS Transactions, 
                           1 TypeId, 
                           SUM(ISNULL(PL.Usd, 0)) + SUM(ISNULL(PL.CardPaymentFee, 0)) + SUM(ISNULL(PL.Fee1, 0)) - SUM(ISNULL(PC.Usd, 0)) AS Usd, 
                           --SUM(ISNULL(PL.CardPaymentFee, 0)) + SUM(ISNULL(PL.Fee1, 0)) - SUM(ISNULL(PC.Usd, 0)) AS FeeService, 
                           SUM(ISNULL(PL.CardPaymentFee, 0)) AS FeeService, 
                           0 Credit, 
                           --SUM(ISNULL(PL.CardPaymentFee, 0)) + SUM(ISNULL(PL.Fee1, 0)) - SUM(ISNULL(PC.Usd, 0)) AS BalanceDetail
                           SUM(ISNULL(PL.CardPaymentFee, 0)) AS BalanceDetail
                    FROM dbo.PromotionalCodes AS PC
                         INNER JOIN dbo.PromotionalCodesStatus AS PS ON PC.PromotionalCodeId = PS.PromotionalCodeId
                         RIGHT OUTER JOIN dbo.PlateStickers AS PL
                         INNER JOIN dbo.Agencies AS A ON A.AgencyId = PL.AgencyId ON PS.PlateStickerId = PL.PlateStickerId
                    WHERE A.AgencyId = @AgencyId
                          AND PL.cardpayment = 1
                          AND (@FromCommissions = 1
                               AND (CAST(DATEPART(month, PL.CreationDate) AS INT) = @Month
                                    AND CAST(DATEPART(year, PL.CreationDate) AS INT) = @Year)
                               OR @FromCommissions = 0
                               AND (CAST(PL.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                                    AND CAST(PL.CreationDate AS DATE) <= CAST(@ToDate AS DATE)))
                    GROUP BY PL.AgencyId, 
                             CAST(PL.CreationDate AS DATE)
                    UNION ALL --Titles
                    SELECT TS.AgencyId, 
                           CAST(TS.CreationDate AS DATE) AS DATE, 
                           'CLOSING DAILY' Description, 
                           'CARD PAYMENT FEE' Type, 
                           COUNT(*) AS Transactions, 
                           1 TypeId, 
                           SUM(ISNULL(TS.Usd, 0)) + SUM(ISNULL(TS.CardPaymentFee, 0)) + SUM(ISNULL(TS.Fee1, 0)) - SUM(ISNULL(PC.Usd, 0)) AS Usd, 
                           --SUM(ISNULL(TS.CardPaymentFee, 0)) + SUM(ISNULL(TS.Fee1, 0)) - SUM(ISNULL(PC.Usd, 0)) AS FeeService, 
                           SUM(ISNULL(TS.CardPaymentFee, 0)) AS FeeService, 
                           0 Credit, 
                           --SUM(ISNULL(TS.CardPaymentFee, 0)) + SUM(ISNULL(TS.Fee1, 0)) - SUM(ISNULL(PC.Usd, 0)) AS BalanceDetail
                           SUM(ISNULL(TS.CardPaymentFee, 0)) AS BalanceDetail
                    FROM dbo.PromotionalCodes AS PC
                         INNER JOIN dbo.PromotionalCodesStatus AS PS ON PC.PromotionalCodeId = PS.PromotionalCodeId
                         RIGHT OUTER JOIN dbo.Titles AS TS
                         INNER JOIN dbo.Agencies AS A ON A.AgencyId = TS.AgencyId ON PS.TitleId = TS.TitleId
                    WHERE A.AgencyId = @AgencyId
                          AND TS.cardpayment = 1
                          AND (@FromCommissions = 1
                               AND (CAST(DATEPART(month, TS.CreationDate) AS INT) = @Month
                                    AND CAST(DATEPART(year, TS.CreationDate) AS INT) = @Year)
                               OR @FromCommissions = 0
                               AND (CAST(TS.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                                    AND CAST(TS.CreationDate AS DATE) <= CAST(@ToDate AS DATE)))
                    GROUP BY TS.AgencyId, 
                             CAST(TS.CreationDate AS DATE)
                    UNION ALL --Parkingtickets
                    SELECT P.AgencyId, 
                           CAST(P.CreationDate AS DATE) AS DATE, 
                           'CLOSING DAILY' Description, 
                           'CARD PAYMENT FEE' Type, 
                           COUNT(*) AS Transactions, 
                           1 TypeId, 
                           SUM(ISNULL(P.Usd, 0)) + SUM(ISNULL(P.CardPaymentFee, 0)) + SUM(ISNULL(P.Fee1, 0)) + SUM(ISNULL(P.Fee2, 0)) AS Debit, 
                           --SUM(ISNULL(P.CardPaymentFee, 0)) + SUM(ISNULL(P.Fee1, 0)) + SUM(ISNULL(P.Fee2, 0)) AS FeeService, 
                           SUM(ISNULL(P.CardPaymentFee, 0)) AS FeeService, 
                           0 Credit, 
                           --SUM(ISNULL(P.CardPaymentFee, 0)) + SUM(ISNULL(P.Fee1, 0)) + SUM(ISNULL(P.Fee2, 0)) AS BalanceDetail
                           SUM(ISNULL(P.CardPaymentFee, 0)) AS BalanceDetail
                    FROM Parkingtickets P
                         INNER JOIN Agencies A ON A.AgencyId = P.AgencyId
                    WHERE A.AgencyId = @AgencyId
                          AND P.cardpayment = 1
                          AND (@FromCommissions = 1
                               AND (CAST(DATEPART(month, CreationDate) AS INT) = @Month
                                    AND CAST(DATEPART(year, CreationDate) AS INT) = @Year)
                               OR @FromCommissions = 0
                               AND (CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                                    AND CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)))
                    GROUP BY P.AgencyId, 
                             CAST(P.CreationDate AS DATE)
                    UNION ALL --Tickets
                    SELECT PK.AgencyId, 
                           CAST(PK.CreationDate AS DATE) AS DATE, 
                           'CLOSING DAILY' Description, 
                           'CARD PAYMENT FEE' Type, 
                           COUNT(*) AS Transactions, 
                           1 TypeId, 
                           SUM(ISNULL(PK.Usd, 0)) + SUM(ISNULL(PK.CardPaymentFee, 0)) + SUM(ISNULL(PK.Fee1, 0)) + SUM(ISNULL(PK.Fee2, 0)) AS Usd, 
                           --SUM(ISNULL(PK.CardPaymentFee, 0)) + SUM(ISNULL(PK.Fee1, 0)) + SUM(ISNULL(PK.Fee2, 0)) AS FeeService, 
                           SUM(ISNULL(PK.CardPaymentFee, 0)) AS FeeService, 
                           0 Credit, 
                           --SUM(ISNULL(PK.CardPaymentFee, 0)) + SUM(ISNULL(PK.Fee1, 0)) + SUM(ISNULL(PK.Fee2, 0)) AS BalanceDetail
                           SUM(ISNULL(PK.CardPaymentFee, 0)) AS BalanceDetail
                    FROM Tickets PK
                         INNER JOIN Agencies A ON A.AgencyId = PK.AgencyId
                    WHERE A.AgencyId = @AgencyId
                          AND PK.cardpayment = 1
                          AND (@FromCommissions = 1
                               AND (CAST(DATEPART(month, CreationDate) AS INT) = @Month
                                    AND CAST(DATEPART(year, CreationDate) AS INT) = @Year)
                               OR @FromCommissions = 0
                               AND (CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                                    AND CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)))
                    GROUP BY PK.AgencyId, 
                             CAST(PK.CreationDate AS DATE)
                    UNION ALL --titleInquiry
                    SELECT TI.AgencyId, 
                           CAST(TI.CreationDate AS DATE) AS DATE, 
                           'CLOSING DAILY' Description, 
                           'CARD PAYMENT FEE' Type, 
                           COUNT(*) AS Transactions, 
                           1 TypeId, 
                           SUM(ISNULL(TI.Usd, 0)) + SUM(ISNULL(TI.CardPaymentFee, 0)) + SUM(ISNULL(TI.Fee1, 0)) AS Usd, 
                           --SUM(ISNULL(TI.CardPaymentFee, 0)) + SUM(ISNULL(TI.Fee1, 0)) AS FeeService, 
                           SUM(ISNULL(TI.CardPaymentFee, 0)) AS FeeService, 
                           0 Credit, 
                           --SUM(ISNULL(TI.CardPaymentFee, 0)) + SUM(ISNULL(TI.Fee1, 0)) AS BalanceDetail
                           SUM(ISNULL(TI.CardPaymentFee, 0)) AS BalanceDetail
                    FROM titleInquiry TI
                         INNER JOIN Agencies A ON A.AgencyId = TI.AgencyId
                    WHERE A.AgencyId = @AgencyId
                          AND TI.cardpayment = 1
                          AND (@FromCommissions = 1
                               AND (CAST(DATEPART(month, CreationDate) AS INT) = @Month
                                    AND CAST(DATEPART(year, CreationDate) AS INT) = @Year)
                               OR @FromCommissions = 0
                               AND (CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                                    AND CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)))
                    GROUP BY TI.AgencyId, 
                             CAST(TI.CreationDate AS DATE)
                    UNION ALL --TRP
                    SELECT TR.AgencyId, 
                           CAST(TR.CreatedOn AS DATE) AS DATE, 
                           'CLOSING DAILY' Description, 
                           'CARD PAYMENT FEE' Type, 
                           COUNT(*) AS Transactions, 
                           1 TypeId, 
                           SUM(ISNULL(TR.Usd, 0)) + SUM(ISNULL(TR.CardPaymentFee, 0)) + SUM(ISNULL(TR.LaminationFee, 0)) AS Usd, 
                           --SUM(ISNULL(TR.CardPaymentFee, 0)) + SUM(ISNULL(TR.LaminationFee, 0)) AS FeeService, 
                           SUM(ISNULL(TR.CardPaymentFee, 0)) AS FeeService, 
                           0 Credit, 
                           --SUM(ISNULL(TR.CardPaymentFee, 0)) + SUM(ISNULL(TR.LaminationFee, 0)) AS BalanceDetail
                           SUM(ISNULL(TR.CardPaymentFee, 0)) AS BalanceDetail
                    FROM TRP TR
                         INNER JOIN Agencies A ON A.AgencyId = TR.AgencyId
                    WHERE A.AgencyId = @AgencyId
                          AND TR.cardpayment = 1
                          AND (@FromCommissions = 1
                               AND (CAST(DATEPART(month, CreatedOn) AS INT) = @Month
                                    AND CAST(DATEPART(year, CreatedOn) AS INT) = @Year)
                               OR @FromCommissions = 0
                               AND (CAST(CreatedOn AS DATE) >= CAST(@FromDate AS DATE)
                                    AND CAST(CreatedOn AS DATE) <= CAST(@ToDate AS DATE)))
                    GROUP BY TR.AgencyId, 
                             CAST(TR.CreatedOn AS DATE)
                    UNION ALL --OtherPayments
                    SELECT OP.AgencyId, 
                           CAST(OP.CreationDate AS DATE) AS DATE, 
                           'CLOSING DAILY' Description, 
                           'CARD PAYMENT FEE' Type,
                           --'OtherPayment' Type, 
                           COUNT(*) AS Transactions, 
                           1 TypeId, 
                           SUM(ISNULL(OP.Usd, 0)) + SUM(ISNULL(OP.CardPaymentFee, 0)) AS Usd, 
                           SUM(ISNULL(OP.CardPaymentFee, 0)) AS FeeService, 
                           0 Credit, 
                           SUM(ISNULL(OP.CardPaymentFee, 0)) AS BalanceDetail
                    FROM OtherPayments OP
                         INNER JOIN Agencies A ON A.AgencyId = OP.AgencyId
                    WHERE A.AgencyId = @AgencyId
                          AND OP.CardPayment = 1
                          AND (@FromCommissions = 1
                               AND (CAST(DATEPART(month, CreationDate) AS INT) = @Month
                                    AND CAST(DATEPART(year, CreationDate) AS INT) = @Year)
                               OR @FromCommissions = 0
                               AND (CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                                    AND CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)))
                    GROUP BY OP.AgencyId, 
                             CAST(OP.CreationDate AS DATE)
                    UNION ALL --OthersDetails
                    SELECT OD.AgencyId, 
                           CAST(OD.CreationDate AS DATE) AS DATE, 
                           'CLOSING DAILY' Description, 
                           'CARD PAYMENT FEE' Type,
                           --'OtherDetails' Type, 
                           COUNT(*) AS Transactions, 
                           1 TypeId, 
                           SUM(ISNULL(OD.Usd, 0)) + SUM(ISNULL(OD.CardPaymentFee, 0)) AS Usd, 
                           SUM(ISNULL(OD.CardPaymentFee, 0)) AS FeeService, 
                           0 Credit, 
                           SUM(ISNULL(OD.CardPaymentFee, 0)) AS BalanceDetail
                    FROM OthersDetails OD
                         INNER JOIN Agencies A ON A.AgencyId = OD.AgencyId
                    WHERE A.AgencyId = @AgencyId
                          AND OD.CardPayment = 1
                          AND (@FromCommissions = 1
                               AND (CAST(DATEPART(month, CreationDate) AS INT) = @Month
                                    AND CAST(DATEPART(year, CreationDate) AS INT) = @Year)
                               OR @FromCommissions = 0
                               AND (CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                                    AND CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)))
                    GROUP BY OD.AgencyId, 
                             CAST(OD.CreationDate AS DATE)
                    UNION ALL --HeadphonesAndChargers
                    SELECT HC.AgencyId, 
                           CAST(HC.CreationDate AS DATE) AS DATE, 
                           'CLOSING DAILY' Description, 
                           'CARD PAYMENT FEE' Type,
                           --'OtherDetails' Type, 
                           COUNT(*) AS Transactions, 
                           1 TypeId, 
                           CAST(SUM(ISNULL(HC.HeadphonesUsd, 0)) + SUM(ISNULL(HC.ChargersUsd, 0)) + SUM(ISNULL(HC.CardPaymentFee, 0)) AS NUMERIC(18, 2)) AS Usd, 
                           SUM(ISNULL(HC.CardPaymentFee, 0)) AS FeeService, 
                           0 Credit, 
                           SUM(ISNULL(HC.CardPaymentFee, 0)) AS BalanceDetail
                    FROM HeadphonesAndChargers HC
                         INNER JOIN Agencies A ON A.AgencyId = HC.AgencyId
                    WHERE A.AgencyId = @AgencyId
                          AND HC.CardPayment = 1
                          AND (@FromCommissions = 1
                               AND (CAST(DATEPART(month, CreationDate) AS INT) = @Month
                                    AND CAST(DATEPART(year, CreationDate) AS INT) = @Year)
                               OR @FromCommissions = 0
                               AND (CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                                    AND CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)))
                    GROUP BY HC.AgencyId, 
                             CAST(HC.CreationDate AS DATE)
                    UNION ALL --Phone sales
                    SELECT A.AgencyId, 
                           CAST(p.CreationDate AS DATE) AS DATE, 
                           'CLOSING DAILY' Description, 
                           'CARD PAYMENT FEE' Type,
                           --'OtherDetails' Type, 
                           COUNT(*) AS Transactions, 
                           1 TypeId, 
                           CAST(SUM(ISNULL(p.SellingValue, 0))  + SUM(ISNULL(pp.Usd, 0))  + ((SUM(ISNULL(p.SellingValue, 0))  * SUM(ISNULL(p.Tax, 0)) ) / 100 ) + SUM(ISNULL(p.CardPaymentFee, 0)) AS NUMERIC(18, 2)) AS Usd, 
                           SUM(ISNULL(P.CardPaymentFee, 0)) AS FeeService, 
                           0 Credit, 
                           SUM(ISNULL(P.CardPaymentFee, 0)) AS BalanceDetail
                    FROM PhoneSales p
                         INNER JOIN InventoryByAgency IA ON IA.InventoryByAgencyId = p.InventoryByAgencyId
                         INNER JOIN Agencies A ON A.AgencyId = IA.AgencyId
                         INNER JOIN Users u ON u.UserId = p.CreatedBy
						 LEFT JOIN PhonePlans pp ON pp.PhonePlanId = p.PhonePlanId
                    WHERE A.AgencyId = @AgencyId
                          AND P.CardPayment = 1
                          AND (@FromCommissions = 1
                               AND (CAST(DATEPART(month, CreationDate) AS INT) = @Month
                                    AND CAST(DATEPART(year, CreationDate) AS INT) = @Year)
                               OR @FromCommissions = 0
                               AND (CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                                    AND CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)))
                    GROUP BY A.AgencyId, 
                             CAST(p.CreationDate AS DATE)
                    UNION ALL --TicketFeeServices
                    SELECT fs.AgencyId, 
                           CAST(fs.CreationDate AS DATE) AS DATE, 
                           'CLOSING DAILY' Description, 
                           'CARD PAYMENT FEE' Type,
                           --'OtherDetails' Type, 
                           COUNT(*) AS Transactions, 
                           1 TypeId, 
                           SUM(ISNULL(fs.Usd, 0)) + SUM(ISNULL(fs.CardPaymentFee, 0)) AS Usd, 
                           SUM(ISNULL(fs.CardPaymentFee, 0)) AS FeeService, 
                           0 Credit, 
                           SUM(ISNULL(fs.CardPaymentFee, 0)) AS BalanceDetail
                    FROM TicketFeeServices fs
                         INNER JOIN Agencies A ON A.AgencyId = fs.AgencyId
                    WHERE A.AgencyId = @AgencyId
                          AND fs.UsedCard = 1
                          AND (@FromCommissions = 1
                               AND (CAST(DATEPART(month, CreationDate) AS INT) = @Month
                                    AND CAST(DATEPART(year, CreationDate) AS INT) = @Year)
                               OR @FromCommissions = 0
                               AND (CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                                    AND CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)))
                    GROUP BY fs.AgencyId, 
                             CAST(fs.CreationDate AS DATE)
                    UNION ALL --SystemToolsBill
                    SELECT S.AgencyId, 
                           CAST(S.CreationDate AS DATE) AS DATE, 
                           'CLOSING DAILY' Description, 
                           'CARD PAYMENT FEE' Type, 
                           COUNT(*) AS Transactions, 
                           1 TypeId, 
                           SUM(ISNULL(S.Total, 0)) AS Usd, 
                           SUM(ISNULL(S.CardPaymentFee, 0)) AS FeeService, 
                           0 Credit, 
                           SUM(ISNULL(S.CardPaymentFee, 0)) AS BalanceDetail
                    FROM SystemToolsBill s
                         INNER JOIN Agencies A ON A.AgencyId = s.AgencyId
                    WHERE A.AgencyId = @AgencyId
                          AND s.CardPayment = 1
                          AND (@FromCommissions = 1
                               AND (CAST(DATEPART(month, CreationDate) AS INT) = @Month
                                    AND CAST(DATEPART(year, CreationDate) AS INT) = @Year)
                               OR @FromCommissions = 0
                               AND (CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                                    AND CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)))
                    GROUP BY s.AgencyId, 
                             CAST(s.CreationDate AS DATE)
                    UNION ALL -- CardPayments
                    SELECT fs.AgencyId, 
                           CAST(fs.CreationDate AS DATE) AS DATE, 
                           'CLOSING DAILY' Description, 
                           'CARD PAYMENT FEE' Type,
                           --'OtherDetails' Type, 
                           sum(fs.NumberPayments) AS Transactions, 
                           1 TypeId, 
                           SUM(ISNULL(fs.Usd, 0)) + SUM(ISNULL(fs.TotalPay, 0)) + SUM(ISNULL(fs.Fee, 0)) + SUM(ISNULL(fs.FeeUsd, 0)) AS Usd, 
                           SUM(ISNULL(fs.Fee, 0)) + SUM(ISNULL(fs.FeeUsd, 0)) AS FeeService, 
                           0 Credit, 
                           SUM(ISNULL(fs.Fee, 0)) + SUM(ISNULL(fs.FeeUsd, 0)) AS BalanceDetail
                    FROM CardPayments fs
                         INNER JOIN Agencies A ON A.AgencyId = fs.AgencyId
                                                  AND (@FromCommissions = 1
                                                       AND (CAST(DATEPART(month, CreationDate) AS INT) = @Month
                                                            AND CAST(DATEPART(year, CreationDate) AS INT) = @Year)
                                                       OR @FromCommissions = 0
                                                       AND (CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                                                            AND CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)))
                    WHERE fs.AgencyId = @AgencyId
                    GROUP BY fs.AgencyId, 
                             CAST(fs.CreationDate AS DATE)
                    UNION ALL
                    SELECT Agencies.AgencyId, 
                           ProviderCommissionPayments.CreationDate DATE, 
                           'COMM. ' + dbo.[fn_GetMonthByNum](Month) + '-' + CAST(Year AS CHAR(4)) Description, 
						   --+ CAST(ProviderCommissionPayments.Month AS varchar(10)) + '-' +  CAST(ProviderCommissionPayments.Year AS varchar(10)) + '-' Description, 
                           'COMMISSION' Type, 
                           --(
                           --    SELECT TOP 1 NumTransactions
                           --    FROM dbo.[FN_GenerateCountTransactions2](@AgencyId, CAST(CAST(CAST(ProviderCommissionPayments.Year AS VARCHAR(100)) + '-' + CAST(ProviderCommissionPayments.Month AS VARCHAR(100)) + '-1' AS VARCHAR(100)) AS DATE),
                           --    (
                           --        SELECT DATEADD(MONTH, ((YEAR(CAST(ProviderCommissionPayments.Year AS VARCHAR(100)) + '-' + CAST(ProviderCommissionPayments.Month AS VARCHAR(100)) + '-01') - 1900) * 12) + MONTH((CAST(ProviderCommissionPayments.Year AS VARCHAR(100)) + '-' + CAST(ProviderCommissionPayments.Month AS VARCHAR(100)) + '-01')), -1)
                           --    )
                           --                                            )
                           --) AS Transactions, 
                           TotalTransactions Transactions,
                           --(SELECT top 1 NumTransactions from dbo.[FN_GenerateCountTransactions](@AgencyId, @FromDate , 
                           --(SELECT DATEADD(MONTH, ((YEAR(ProviderCommissionPayments.Year + '-' +ProviderCommissionPayments.Month + '-1') - 1900) * 12) + MONTH(''), -1)))) AS Transactions, 
                           2 TypeId, 
                           0 Usd, 
                           0 FeeService, 
                           ISNULL(ProviderCommissionPayments.Usd, 0) Credit, 
                           -ISNULL(ProviderCommissionPayments.Usd, 0) BalanceDetail
                    FROM dbo.ProviderCommissionPayments
                         INNER JOIN dbo.Providers ON dbo.ProviderCommissionPayments.ProviderId = dbo.Providers.ProviderId
                         INNER JOIN dbo.ProviderCommissionPaymentTypes ON dbo.ProviderCommissionPayments.ProviderCommissionPaymentTypeId = dbo.ProviderCommissionPaymentTypes.ProviderCommissionPaymentTypeId
                         INNER JOIN dbo.Agencies ON dbo.ProviderCommissionPayments.AgencyId = dbo.Agencies.AgencyId
                         LEFT OUTER JOIN dbo.Bank ON dbo.ProviderCommissionPayments.BankId = dbo.Bank.BankId
                         INNER JOIN dbo.ProviderTypes ON dbo.ProviderTypes.ProviderTypeId = dbo.Providers.ProviderTypeId
                    WHERE(@FromCommissions = 0
                          AND ProviderCommissionPayments.AgencyId = @AgencyId
                          AND ((ProviderCommissionPayments.Year = @YearFrom
                                AND ProviderCommissionPayments.Month >= @MonthFrom)
                               OR (ProviderCommissionPayments.Year > @YearFrom)
                               OR @YearFrom IS NULL)
                          AND ((ProviderCommissionPayments.Year = @YearTo
                                AND ProviderCommissionPayments.Month <= @MonthTo)
                               OR (ProviderCommissionPayments.Year < @YearTo)
                               OR @YearTo IS NULL)
                          AND ProviderCommissionPayments.ProviderId = @ProviderId)
                         OR @FromCommissions = 1
                ) AS ComissionTicketsQuantity
                GROUP BY AgencyId, 
                         Date, 
                         Description, 
                         Type, 
                         TypeId;
         RETURN;
     END;
GO