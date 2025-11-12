SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
cREATE FUNCTION [dbo].[FN_GenerateCountTransactions2](@AgencyId   INT, 
                                                    @FromDate   DATETIME = NULL, 
                                                    @ToDate     DATETIME = NULL
                                                   
                                                   ) 
RETURNS @result TABLE
(NumTransactions INT 
)
AS
     BEGIN
       
             
               
         INSERT INTO @result
         (NumTransactions
         )
         (
                SELECT  SUM(QueryFinal.Transactions) AS NumTransactions
                FROM
                (
                    
               SELECT DP.AgencyId, 
                                  CAST(DP.CreationDate AS DATE) AS DATE, 
                                  'CLOSING DAILY' Description, 
                                  'CARD PAYMENT' Type, 
                                  COUNT(*) AS Transactions, 
                                  1 TypeId, 
                                  SUM(DP.Usd) AS Usd, 
                                  SUM(DP.CardPaymentFee) AS FeeService, 
                                  0 Credit, 
                                  SUM(DP.CardPaymentFee) AS BalanceDetail
                           FROM DepositFinancingPayments DP
                                INNER JOIN Agencies A ON A.AgencyId = DP.AgencyId
                           WHERE A.AgencyId = @AgencyId
                                 AND DP.CardPayment = 1
                                 AND CAST(DP.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                                 AND CAST(DP.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                           GROUP BY DP.AgencyId, 
                                    CAST(DP.CreationDate AS DATE)
                           UNION ALL
                           SELECT RN.AgencyId, 
                                  CAST(RN.CreationDate AS DATE) AS DATE, 
                                  'CLOSING DAILY' Description, 
                                  'CARD PAYMENT' Type, 
                                  COUNT(*) AS Transactions, 
                                  1 TypeId, 
                                  SUM(RN.Usd) AS Usd, 
                                  SUM(ISNULL(RN.CardPaymentFee, 0)) + SUM(ISNULL(RN.FeeDue, 0)) AS FeeService, 
                                  0 Credit, 
                                  SUM(ISNULL(RN.CardPaymentFee, 0)) + SUM(ISNULL(RN.FeeDue, 0)) AS BalanceDetail
                           FROM RentPayments RN
                                INNER JOIN Agencies A ON A.AgencyId = RN.AgencyId
                           WHERE A.AgencyId = @AgencyId
                                 AND RN.CardPayment = 1
                                 AND CAST(RN.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                                 AND CAST(RN.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                           GROUP BY RN.AgencyId, 
                                    CAST(RN.CreationDate AS DATE)
                           UNION ALL
                           SELECT F.AgencyId, 
                                  CAST(P.CreatedOn AS DATE) AS DATE, 
                                  'CLOSING DAILY' Description, 
                                  'CARD PAYMENT' Type, 
                                  COUNT(*) AS Transactions, 
                                  1 TypeId, 
                                  SUM(P.Usd) AS Usd, 
                                  SUM(ISNULL(P.CardPaymentFee, 0)) AS FeeService, 
                                  0 Credit, 
                                  SUM(ISNULL(P.CardPaymentFee, 0)) AS BalanceDetail
                           FROM Financing F
                                INNER JOIN Agencies A ON A.AgencyId = F.AgencyId
                                INNER JOIN Payments P ON P.FinancingId = F.FinancingId
                           WHERE A.AgencyId = @AgencyId
                                 AND P.CardPayment = 1
                                 AND CAST(P.CreatedOn AS DATE) >= CAST(@FromDate AS DATE)
                                 AND CAST(P.CreatedOn AS DATE) <= CAST(@ToDate AS DATE)
                           GROUP BY F.AgencyId, 
                                    CAST(P.CreatedOn AS DATE)
                           UNION ALL
                           SELECT PR.AgencyId, 
                                  CAST(PR.CreationDate AS DATE) AS DATE, 
                                  'CLOSING DAILY' Description, 
                                  'CARD PAYMENT' Type, 
                                  COUNT(*) AS Transactions, 
                                  1 TypeId, 
                                  SUM(ISNULL(PR.Total, 0)) AS Usd, 
                                  SUM(ISNULL(PR.OtherFees, 0)) + SUM(ISNULL(PR.CardPaymentFee, 0)) AS FeeService, 
                                  0 Credit, 
                                  SUM(ISNULL(PR.OtherFees, 0)) + SUM(ISNULL(PR.CardPaymentFee, 0)) AS BalanceDetail
                           FROM ProvisionalReceipts PR
                                INNER JOIN Agencies A ON A.AgencyId = PR.AgencyId
                           WHERE A.AgencyId = @AgencyId
                                 AND PR.CardPayment = 1
                                 AND CAST(PR.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                                 AND CAST(PR.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                           GROUP BY PR.AgencyId, 
                                    CAST(PR.CreationDate AS DATE)
                           UNION ALL
                           SELECT RC.BelongAgencyId, 
                                  CAST(P.CreationDate AS DATE) AS DATE, 
                                  'CLOSING DAILY' Description, 
                                  'CARD PAYMENT' Type, 
                                  COUNT(*) AS Transactions, 
                                  1 TypeId, 
                                  SUM(P.Usd) AS Usd, 
                                  SUM(ISNULL(P.CardPaymentFee, 0)) AS FeeService, 
                                  0 Credit, 
                                  SUM(ISNULL(P.CardPaymentFee, 0)) AS BalanceDetail
                           FROM ReturnedCheck RC
                                INNER JOIN Agencies A ON A.AgencyId = RC.BelongAgencyId
                                INNER JOIN ReturnPayments P ON P.ReturnedCheckId = RC.ReturnedCheckId
                           WHERE A.AgencyId = @AgencyId
                                 AND P.CardPayment = 1
                                 AND CAST(P.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                                 AND CAST(P.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                           GROUP BY RC.BelongAgencyId, 
                                    CAST(P.CreationDate AS DATE)
                           UNION ALL
                           SELECT T.AgencyId, 
                                  CAST(T.CreationDate AS DATE) AS DATE, 
                                  'CLOSING DAILY' Description, 
                                  'CARD PAYMENT' Type, 
                                  COUNT(*) AS Transactions, 
                                  1 TypeId, 
                                  SUM(T.Usd) AS Usd, 
                                  SUM(ISNULL(T.Fee1, 0)) + SUM(ISNULL(T.CardPaymentFee, 0)) AS FeeService, 
                                  0 Credit, 
                                  SUM(ISNULL(T.Fee1, 0)) + SUM(ISNULL(T.CardPaymentFee, 0)) AS BalanceDetail
                           FROM CountryTaxes T
                                INNER JOIN Agencies A ON A.AgencyId = T.AgencyId
                           WHERE A.AgencyId = @AgencyId
                                 AND T.cardpayment = 1
                                 AND CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                                 AND CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                           GROUP BY T.AgencyId, 
                                    CAST(T.CreationDate AS DATE)
                           UNION ALL
                           SELECT C.AgencyId, 
                                  CAST(C.CreationDate AS DATE) AS DATE, 
                                  'CLOSING DAILY' Description, 
                                  'CARD PAYMENT' Type, 
                                  COUNT(*) AS Transactions, 
                                  1 TypeId, 
                                  SUM(C.Usd) AS Usd, 
                                  SUM(ISNULL(C.CardPaymentFee, 0)) + SUM(ISNULL(C.Fee1, 0)) - SUM(ISNULL(PC.Usd, 0)) AS FeeService, 
                                  0 Credit, 
                                  SUM(ISNULL(C.CardPaymentFee, 0)) + SUM(ISNULL(C.Fee1, 0)) - SUM(ISNULL(PC.Usd, 0)) AS BalanceDetail
                           FROM dbo.PromotionalCodes AS PC
                                INNER JOIN dbo.PromotionalCodesStatus AS PS ON PC.PromotionalCodeId = PS.PromotionalCodeId
                                RIGHT OUTER JOIN dbo.CityStickers AS C
                                INNER JOIN dbo.Agencies AS A ON A.AgencyId = C.AgencyId ON PS.CityStickerId = C.CityStickerId
                           WHERE A.AgencyId = @AgencyId
                                 AND C.cardpayment = 1
                                 AND CAST(C.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                                 AND CAST(C.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                           GROUP BY C.AgencyId, 
                                    CAST(C.CreationDate AS DATE)
                           UNION ALL
                           SELECT PK.AgencyId, 
                                  CAST(PK.CreationDate AS DATE) AS DATE, 
                                  'CLOSING DAILY' Description, 
                                  'CARD PAYMENT' Type, 
                                  COUNT(*) AS Transactions, 
                                  1 TypeId, 
                                  SUM(PK.Usd) AS Usd, 
                                  SUM(ISNULL(PK.CardPaymentFee, 0)) + SUM(ISNULL(PK.Fee1, 0)) + SUM(ISNULL(PK.Fee2, 0)) AS FeeService, 
                                  0 Credit, 
                                  SUM(ISNULL(PK.CardPaymentFee, 0)) + SUM(ISNULL(PK.Fee1, 0)) + SUM(ISNULL(PK.Fee2, 0)) AS BalanceDetail
                           FROM Parkingticketscards PK
                                INNER JOIN Agencies A ON A.AgencyId = PK.AgencyId
                           WHERE A.AgencyId = @AgencyId
                                 AND PK.cardpayment = 1
                                 AND CAST(PK.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                                 AND CAST(PK.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                           GROUP BY PK.AgencyId, 
                                    CAST(PK.CreationDate AS DATE)
                           UNION ALL
                           SELECT P.AgencyId, 
                                  CAST(P.CreationDate AS DATE) AS DATE, 
                                  'CLOSING DAILY' Description, 
                                  'CARD PAYMENT' Type, 
                                  COUNT(*) AS Transactions, 
                                  1 TypeId, 
                                  SUM(P.Usd) AS Debit, 
                                  SUM(ISNULL(P.CardPaymentFee, 0)) + SUM(ISNULL(P.Fee1, 0)) + SUM(ISNULL(P.Fee2, 0)) AS FeeService, 
                                  0 Credit, 
                                  SUM(ISNULL(P.CardPaymentFee, 0)) + SUM(ISNULL(P.Fee1, 0)) + SUM(ISNULL(P.Fee2, 0)) AS BalanceDetail
                           FROM Parkingtickets P
                                INNER JOIN Agencies A ON A.AgencyId = P.AgencyId
                           WHERE A.AgencyId = @AgencyId
                                 AND P.cardpayment = 1
                                 AND CAST(P.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                                 AND CAST(P.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                           GROUP BY P.AgencyId, 
                                    CAST(P.CreationDate AS DATE)
                           UNION ALL
                           SELECT TI.AgencyId, 
                                  CAST(TI.CreationDate AS DATE) AS DATE, 
                                  'CLOSING DAILY' Description, 
                                  'CARD PAYMENT' Type, 
                                  COUNT(*) AS Transactions, 
                                  1 TypeId, 
                                  SUM(TI.Usd) AS Usd, 
                                  SUM(ISNULL(TI.CardPaymentFee, 0)) + SUM(ISNULL(TI.Fee1, 0)) AS FeeService, 
                                  0 Credit, 
                                  SUM(ISNULL(TI.CardPaymentFee, 0)) + SUM(ISNULL(TI.Fee1, 0)) AS BalanceDetail
                           FROM titleInquiry TI
                                INNER JOIN Agencies A ON A.AgencyId = TI.AgencyId
                           WHERE A.AgencyId = @AgencyId
                                 AND TI.cardpayment = 1
                                 AND CAST(TI.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                                 AND CAST(TI.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                           GROUP BY TI.AgencyId, 
                                    CAST(TI.CreationDate AS DATE)
                           UNION ALL
                           SELECT PL.AgencyId, 
                                  CAST(PL.CreationDate AS DATE) AS DATE, 
                                  'CLOSING DAILY' Description, 
                                  'CARD PAYMENT' Type, 
                                  COUNT(*) AS Transactions, 
                                  1 TypeId, 
                                  SUM(PL.Usd) AS Usd, 
                                  SUM(ISNULL(PL.CardPaymentFee, 0)) + SUM(ISNULL(PL.Fee1, 0)) - SUM(ISNULL(PC.Usd, 0)) AS FeeService, 
                                  0 Credit, 
                                  SUM(ISNULL(PL.CardPaymentFee, 0)) + SUM(ISNULL(PL.Fee1, 0)) - SUM(ISNULL(PC.Usd, 0)) AS BalanceDetail
                           FROM dbo.PromotionalCodes AS PC
                                INNER JOIN dbo.PromotionalCodesStatus AS PS ON PC.PromotionalCodeId = PS.PromotionalCodeId
                                RIGHT OUTER JOIN dbo.PlateStickers AS PL
                                INNER JOIN dbo.Agencies AS A ON A.AgencyId = PL.AgencyId ON PS.PlateStickerId = PL.PlateStickerId
                           WHERE A.AgencyId = @AgencyId
                                 AND PL.cardpayment = 1
                                 AND CAST(PL.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                                 AND CAST(PL.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                           GROUP BY PL.AgencyId, 
                                    CAST(PL.CreationDate AS DATE)
                           UNION ALL
                           SELECT TS.AgencyId, 
                                  CAST(TS.CreationDate AS DATE) AS DATE, 
                                  'CLOSING DAILY' Description, 
                                  'CARD PAYMENT' Type, 
                                  COUNT(*) AS Transactions, 
                                  1 TypeId, 
                                  SUM(TS.Usd) AS Usd, 
                                  SUM(ISNULL(TS.CardPaymentFee, 0)) + SUM(ISNULL(TS.Fee1, 0)) - SUM(ISNULL(PC.Usd, 0)) AS FeeService, 
                                  0 Credit, 
                                  SUM(ISNULL(TS.CardPaymentFee, 0)) + SUM(ISNULL(TS.Fee1, 0)) - SUM(ISNULL(PC.Usd, 0)) AS BalanceDetail
                           FROM dbo.PromotionalCodes AS PC
                                INNER JOIN dbo.PromotionalCodesStatus AS PS ON PC.PromotionalCodeId = PS.PromotionalCodeId
                                RIGHT OUTER JOIN dbo.Titles AS TS
                                INNER JOIN dbo.Agencies AS A ON A.AgencyId = TS.AgencyId ON PS.TitleId = TS.TitleId
                           WHERE A.AgencyId = @AgencyId
                                 AND TS.cardpayment = 1
                                 AND CAST(TS.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                                 AND CAST(TS.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                           GROUP BY TS.AgencyId, 
                                    CAST(TS.CreationDate AS DATE)
                           UNION ALL
                           SELECT TR.AgencyId, 
                                  CAST(TR.CreatedOn AS DATE) AS DATE, 
                                  'CLOSING DAILY' Description, 
                                  'CARD PAYMENT' Type, 
                                  COUNT(*) AS Transactions, 
                                  1 TypeId, 
                                  SUM(TR.Usd) AS Usd, 
                                  SUM(ISNULL(TR.CardPaymentFee, 0)) + SUM(ISNULL(TR.Fee1, 0)) AS FeeService, 
                                  0 Credit, 
                                  SUM(ISNULL(TR.CardPaymentFee, 0)) + SUM(ISNULL(TR.Fee1, 0)) AS BalanceDetail
                           FROM TRP TR
                                INNER JOIN Agencies A ON A.AgencyId = TR.AgencyId
                           WHERE A.AgencyId = @AgencyId
                                 AND TR.cardpayment = 1
                                 AND CAST(TR.CreatedOn AS DATE) >= CAST(@FromDate AS DATE)
                                 AND CAST(TR.CreatedOn AS DATE) <= CAST(@ToDate AS DATE)
                           GROUP BY TR.AgencyId, 
                                    CAST(TR.CreatedOn AS DATE)
                           
                ) AS QueryFinal
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