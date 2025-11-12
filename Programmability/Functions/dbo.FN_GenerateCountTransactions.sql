SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[FN_GenerateCountTransactions](@AgencyId   INT, 
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
                              SUM(RN.CardPaymentFee) AS FeeService, 
                              0 Credit, 
                              SUM(RN.CardPaymentFee) AS BalanceDetail
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
                              CAST(F.CreatedOn AS DATE) AS DATE, 
                              'CLOSING DAILY' Description, 
                              'CARD PAYMENT' Type, 
                              COUNT(*) AS Transactions, 
                              1 TypeId, 
                              SUM(F.Usd) AS Usd, 
                              SUM(P.CardPaymentFee) AS FeeService, 
                              0 Credit, 
                              SUM(P.CardPaymentFee) AS BalanceDetail
                       FROM Financing F
                            INNER JOIN Agencies A ON A.AgencyId = F.AgencyId
                            INNER JOIN Payments P ON P.FinancingId = F.FinancingId
                       WHERE A.AgencyId = @AgencyId
                             AND P.CardPayment = 1
                             AND CAST(F.CreatedOn AS DATE) >= CAST(@FromDate AS DATE)
                             AND CAST(F.CreatedOn AS DATE) <= CAST(@ToDate AS DATE)
                       GROUP BY F.AgencyId, 
                                CAST(F.CreatedOn AS DATE)
                       UNION ALL
                       SELECT PR.AgencyId, 
                              CAST(PR.CreationDate AS DATE) AS DATE, 
                              'CLOSING DAILY' Description, 
                              'CARD PAYMENT' Type, 
                              COUNT(*) AS Transactions, 
                              1 TypeId, 
                              SUM(PR.Total) AS Usd, 
                              SUM(PR.OtherFees) AS FeeService, 
                              0 Credit, 
                              SUM(PR.OtherFees) AS BalanceDetail
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
                              CAST(RC.CreationDate AS DATE) AS DATE, 
                              'CLOSING DAILY' Description, 
                              'CARD PAYMENT' Type, 
                              COUNT(*) AS Transactions, 
                              1 TypeId, 
                              SUM(RC.Usd) AS Usd, 
                              SUM(RC.Fee) AS FeeService, 
                              0 Credit, 
                              SUM(RC.Fee) AS BalanceDetail
                       FROM ReturnedCheck RC
                            INNER JOIN Agencies A ON A.AgencyId = RC.BelongAgencyId
                       WHERE A.AgencyId = @AgencyId
                             AND RC.CardPayment = 1
                             AND CAST(RC.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                             AND CAST(RC.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                       GROUP BY RC.BelongAgencyId, 
                                CAST(RC.CreationDate AS DATE)
                       UNION ALL
                       SELECT T.AgencyId, 
                              CAST(T.CreationDate AS DATE) AS DATE, 
                              'CLOSING DAILY' Description, 
                              'CARD PAYMENT' Type, 
                              COUNT(*) AS Transactions, 
                              1 TypeId, 
                              SUM(T.Usd) AS Usd, 
                              SUM(T.Fee1) AS FeeService, 
                              0 Credit, 
                              SUM(T.Fee1) AS BalanceDetail
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
                              SUM(C.Fee1) AS FeeService, 
                              0 Credit, 
                              SUM(C.Fee1) AS BalanceDetail
                       FROM CityStickers C
                            INNER JOIN Agencies A ON A.AgencyId = C.AgencyId
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
                              SUM(PK.Fee1) AS FeeService, 
                              0 Credit, 
                              SUM(PK.Fee1) AS BalanceDetail
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
                              SUM(P.Fee1) AS FeeService, 
                              0 Credit, 
                              SUM(P.Fee1) AS BalanceDetail
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
                              SUM(TI.Fee1) AS FeeService, 
                              0 Credit, 
                              SUM(TI.Fee1) AS BalanceDetail
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
                              SUM(PL.Fee1) AS FeeService, 
                              0 Credit, 
                              SUM(PL.Fee1) AS BalanceDetail
                       FROM Platestickers PL
                            INNER JOIN Agencies A ON A.AgencyId = PL.AgencyId
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
                              SUM(TS.Fee1) AS FeeService, 
                              0 Credit, 
                              SUM(TS.Fee1) AS BalanceDetail
                       FROM Titles TS
                            INNER JOIN Agencies A ON A.AgencyId = TS.AgencyId
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
                              SUM(TR.Fee1) AS FeeService, 
                              0 Credit, 
                              SUM(TR.Fee1) AS BalanceDetail
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