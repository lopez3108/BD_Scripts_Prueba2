SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetReportDailySales]
(@AgencyId INT, 
 @FromDate DATETIME = NULL, 
 @ToDate   DATETIME = NULL, 
 @Date     DATETIME
)
AS
    BEGIN
        IF(@FromDate IS NULL)
            BEGIN
                SET @FromDate = DATEADD(day, -10, @Date);
                SET @ToDate = @Date;
            END;
        SELECT *
        FROM
        (

		 SELECT 'BILL PAYMENT' Type, 
                   'CLOSING DAILY' Description, 
                   ISNULL(COUNT(*), 0) Transactions, 
                   ISNULL(SUM(ABS(T.Usd)), 0) Usd
            FROM dbo.BillPayments T
            WHERE T.AgencyId = @agencyId
                  AND CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                  AND CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
            UNION ALL

            --MONEY TRANSFER 1

            SELECT 'MONEY TRANSFER (M.T)' Type, 
                   'CLOSING DAILY' Description, 
                   ISNULL(SUM(T.Transactions), 0) Transactions, 
                   ISNULL(SUM(T.Usd), 0) Usd
            FROM MoneyTransfers T
            WHERE T.AgencyId = @AgencyId
                  AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                       OR @FromDate IS NULL)
                  AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                       OR @ToDate IS NULL)
            UNION ALL
            --MONEY TRANSFER M.O
            SELECT 'MONEY TRANSFER (M.O) ' Type, 
                   'CLOSING DAILY ' Description, 
                   SUM(ISNULL(T.TransactionsNumberMoneyOrders, 0)) Transactions, 
                   SUM(ISNULL(T.UsdMoneyOrders, 0)) AS Usd
            FROM MoneyTransfers T
            WHERE T.AgencyId = @AgencyId
                  AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                       OR @FromDate IS NULL)
                  AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                       OR @ToDate IS NULL)
            UNION ALL

            --PAYROLL CHECK 2

            SELECT 'PAYROLL CHECK' Type, 
                   'CLOSING DAILY' Description, 
                   ISNULL(COUNT(*), 0) Transactions, 
                   ISNULL(SUM(T.Amount), 0) Usd
            FROM ChecksEls T
                 INNER JOIN ProviderTypes p ON t.ProviderTypeId = p.ProviderTypeId
            WHERE P.Code = 'C03'
                  AND T.AgencyId = @AgencyId
                  AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                       OR @FromDate IS NULL)
                  AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                       OR @ToDate IS NULL)
            UNION ALL
            --TAX CHECK 3

            SELECT 'TAX CHECK' Type, 
                   'CLOSING DAILY' Description, 
                   ISNULL(COUNT(*), 0) Transactions, 
                   ISNULL(SUM(T.Amount), 0) Usd
            FROM ChecksEls T
                 INNER JOIN ProviderTypes p ON t.ProviderTypeId = p.ProviderTypeId
            WHERE P.Code = 'C04'
                  AND T.AgencyId = @AgencyId
                  AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                       OR @FromDate IS NULL)
                  AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                       OR @ToDate IS NULL)
            UNION ALL
            --CANCELLATIONS 4

            SELECT q.Type, 
                   q.Description, 
                   ISNULL(SUM(Q.Transactions), 0) Transactions, 
                   ISNULL(SUM(Q.Usd), 0)
            FROM
            (
                SELECT 'CANCELLATIONS' Type, 
                       'CLOSING DAILY' Description, 
                       ISNULL(COUNT(*), 0) Transactions, 
                       ISNULL(CASE
                                  WHEN CAST(t.RefundDate AS DATE) IS NOT NULL
                                       AND RefundFee = 1
                                  THEN(SUM(ABS(t.RefundAmount)) + SUM(ABS(t.Fee)))
                                  WHEN CAST(t.RefundDate AS DATE) IS NOT NULL
                                       AND (RefundFee IS NULL
                                            OR RefundFee = 0)
                                  THEN SUM(ABS(t.RefundAmount))
                                  WHEN CAST(t.NewTransactionDate AS DATE) IS NOT NULL
                                  THEN(SUM(ABS(t.TotalTransaction)) + SUM(ABS(t.Fee)))
                              END, 0) AS Usd
                FROM Cancellations t
                WHERE t.AgencyId = @AgencyId
                      AND ((CAST(t.RefundDate AS DATE) >= CAST(@FromDate AS DATE)
                            AND CAST(t.RefundDate AS DATE) <= CAST(@ToDate AS DATE))
                           OR (CAST(t.NewTransactionDate AS DATE) >= CAST(@FromDate AS DATE)
                               AND CAST(t.NewTransactionDate AS DATE) <= CAST(@ToDate AS DATE)))
                GROUP BY CAST(t.RefundDate AS DATE), 
                         CAST(t.NewTransactionDate AS DATE), 
                         t.RefundFee, 
                         t.AgencyId
            ) Q
            GROUP BY Q.Type, 
                     Q.Description
            UNION ALL
            SELECT 'RETURN CHECK' Type, 
                   'CLOSING DAILY' Description, 
                   ISNULL(COUNT(*), 0) Transactions, 
                   ISNULL(SUM(T.Usd + T.ProviderFee), 0) Usd
            FROM dbo.ReturnedCheck T
            WHERE T.ReturnedAgencyId = @AgencyId
                  AND (CAST(T.ReturnDate AS DATE) >= CAST(@FromDate AS DATE)
                       OR @FromDate IS NULL)
                  AND (CAST(T.ReturnDate AS DATE) <= CAST(@ToDate AS DATE)
                       OR @ToDate IS NULL)
            UNION ALL
            SELECT 'RETURN CHECK PAYMENTS' Type, 
                   'CLOSING DAILY' Description, 
                   ISNULL(COUNT(*), 0) Transactions, 
                   ISNULL(SUM(T.Usd), 0) Usd
            FROM ProviderTypes PT
                 INNER JOIN Providers P ON PT.ProviderTypeId = p.ProviderTypeId
                 INNER JOIN dbo.ReturnedCheck rc ON rc.ProviderId = p.ProviderId
                 INNER JOIN ReturnPayments T ON t.ReturnedCheckId = rc.ReturnedCheckId
            WHERE PT.CODE = 'C02'
                  AND T.AgencyId = @AgencyId
                  AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                       OR @FromDate IS NULL)
                  AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                       OR @ToDate IS NULL)
            UNION ALL
            SELECT 'VEHICLE SERVICES' Type, 
                   Description, 
                   ISNULL(SUM(Transactions), 0) Transactions, 
                   ISNULL(SUM(Usd), 0) Usd
            FROM
            (
                SELECT 'CitySticker' Type, 
                       'CLOSING DAILY' Description, 
                       COUNT(*) Transactions, 
                       SUM(T.Usd + t.Fee1 + t.FeeEls + t.CardPaymentFee) Usd
                FROM CityStickers T
                WHERE T.AgencyId = @AgencyId
                      AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                           OR @FromDate IS NULL)
                      AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                           OR @ToDate IS NULL)
                UNION ALL
                SELECT 'CountyTaxes' Type, 
                       'CLOSING DAILY' Description, 
                       COUNT(*) Transactions, 
                       SUM(T.Usd + t.Fee1 + t.FeeEls + t.CardPaymentFee) Usd
                FROM CountryTaxes T
                WHERE T.AgencyId = @AgencyId
                      AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                           OR @FromDate IS NULL)
                      AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                           OR @ToDate IS NULL)
                UNION ALL
                SELECT 'ParkingTicketsCards' Type, 
                       'CLOSING DAILY' Description, 
                       COUNT(*) Transactions, 
                       SUM(T.Usd + t.Fee1 + t.Fee2 + t.CardPaymentFee) Usd
                FROM ParkingTicketsCards T
                WHERE T.AgencyId = @AgencyId
                      AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                           OR @FromDate IS NULL)
                      AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                           OR @ToDate IS NULL)
                UNION ALL
                SELECT 'PlateStickers' Type, 
                       'CLOSING DAILY' Description, 
                       COUNT(*) Transactions, 
                       SUM(T.Usd + t.Fee1 + T.FeeEls + t.CardPaymentFee) Usd
                FROM PlateStickers T
                WHERE T.AgencyId = @AgencyId
                      AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                           OR @FromDate IS NULL)
                      AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                           OR @ToDate IS NULL)
                UNION ALL
                SELECT 'RunnerServices' Type, 
                       'CLOSING DAILY' Description, 
                       SUM(t.NumberTransactions) Transactions, 
                       SUM(T.Usd + T.FeeEls) Usd
                FROM RunnerServices t
                WHERE T.AgencyId = @AgencyId
                      AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                           OR @FromDate IS NULL)
                      AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                           OR @ToDate IS NULL)

                --WHERE A.AgencyId = @AgencyId

                UNION ALL
                SELECT 'TitleInquiry' Type, 
                       'CLOSING DAILY' Description, 
                       COUNT(*) Transactions, 
                       SUM(T.Usd + t.Fee1 + T.FeeEls + t.CardPaymentFee) Usd
                FROM TitleInquiry T
                WHERE T.AgencyId = @AgencyId
                      AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                           OR @FromDate IS NULL)
                      AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                           OR @ToDate IS NULL)
                UNION ALL
                SELECT 'Titles' Type, 
                       'CLOSING DAILY' Description, 
                       COUNT(*) Transactions, 
                       SUM(T.Usd + t.Fee1 + T.FeeEls + t.CardPaymentFee) Usd
                FROM Titles T
                WHERE T.ProcessAuto = 1
                      AND T.AgencyId = @AgencyId
                      AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                           OR @FromDate IS NULL)
                      AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                           OR @ToDate IS NULL)	   
            --UNION ALL  TRP NO VA EN ESTE 
            --SELECT 'TRP' Type,
            --       'CLOSING DAILY' Description,
            --       COUNT(*) Transactions,
            --       SUM(T.Usd + t.Fee1 + T.TrpFee) Usd
            --FROM TRP T

            ) AS Els
            GROUP BY Description
            UNION ALL
            SELECT 'TRP' Type, 
                   'CLOSING DAILY' Description, 
                   ISNULL(COUNT(*), 0) Transactions, 
                   SUM(T.Usd + t.Fee1 + T.TrpFee) Usd
            FROM TRP T
            WHERE T.AgencyId = @AgencyId
                  AND (CAST(T.CreatedOn AS DATE) >= CAST(@FromDate AS DATE)
                       OR @FromDate IS NULL)
                  AND (CAST(T.CreatedOn AS DATE) <= CAST(@ToDate AS DATE)
                       OR @ToDate IS NULL)
            --UNION ALL no existe la seccion.
            --SELECT 'ELS MANUAL' Type, 
            --       'CLOSING DAILY' Description, 
            --       ISNULL(COUNT(*), 0) Transactions, 
            --       ISNULL(SUM(T.Usd + ISNULL(t.Fee1, 0) + ISNULL(T.FeeEls, 0) + ABS(ISNULL(t.FeeILDOR, 0)) + ABS(ISNULL(t.FeeILSOS, 0)) + ABS(ISNULL(t.FeeOther, 0)) + ISNULL(t.FeeOther, 0)), 0) Usd
            --FROM Titles T
            --WHERE T.ProcessAuto = 0
            --      AND T.AgencyId = @AgencyId
            --      AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
            --           OR @FromDate IS NULL)
            --      AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
            --           OR @ToDate IS NULL)

            --TICKETS 
            UNION ALL
            SELECT 'TRAFFIC TICKETS' Type, 
                   Description, 
                   ISNULL(SUM(Transactions), 0) Transactions, 
                   ISNULL(SUM(Usd), 0) Usd
            FROM
            (
                SELECT 'TICKETS FEE SERVICE' Type, 
                       'CLOSING DAILY' Description, 
                       ISNULL(COUNT(*), 0) Transactions, 
                       ISNULL(SUM(t.Usd), 0) Usd
                FROM TicketFeeServices t
                WHERE t.AgencyId = @AgencyId
                      AND CAST(t.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                      AND CAST(t.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                UNION ALL
                SELECT 'TICKETS' Type, 
                       'CLOSING DAILY' Description, 
                       ISNULL(COUNT(*), 0) Transactions, 
                       ISNULL(SUM(ISNULL(t.MoneyOrderFee, 0)) + SUM(t.Usd), 0) Usd
                FROM Tickets t
                WHERE t.UpdateToPendingDate IS NOT NULL
                      AND t.ChangedToPendingByAgency = @AgencyId
                      AND CAST(t.UpdateToPendingDate AS DATE) >= CAST(@FromDate AS DATE)
                      AND CAST(t.UpdateToPendingDate AS DATE) <= CAST(@ToDate AS DATE)
            ) QueryTickets
            GROUP BY Description
            --       UNION ALL NO VA  TAREA 27 27 ESCONDER TODO LO DE FINANACING
            ---- FINANCING 9
            --       SELECT 'FINANCING PAYMENTS' Type,
            --              'CLOSING DAILY' Description,
            --              ISNULL(COUNT(*), 0) Transactions,
            --              ISNULL(SUM(t.CardPaymentFee) + SUM(T.Usd), 0) Usd
            --       FROM Payments T
            --            INNER JOIN Financing f ON f.FinancingId = T.FinancingId
            --       WHERE f.AgencyId = @AgencyId
            --             AND (CAST(T.CreatedOn AS DATE) >= CAST(@FromDate AS DATE)
            --                  OR @FromDate IS NULL)
            --             AND (CAST(T.CreatedOn AS DATE) <= CAST(@ToDate AS DATE)
            --                  OR @ToDate IS NULL)
            
					 	   UNION ALL
            SELECT 'EXTRA FUND RECEIVED FROM CASHIER' Type, 
                  'CLOSING DAILY' Description, 
                   ISNULL(COUNT(*), 0) Transactions, 
                   ISNULL(SUM(ABS(T.Usd)), 0) Usd
            FROM dbo.ExtraFund T
             
            WHERE T.AgencyId = @agencyId
			AND ((T.CashAdmin = 0 AND T.IsCashier = 1) OR (T.CashAdmin = 1 AND T.IsCashier = 0))
                  AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                       OR @FromDate IS NULL)
                  AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                       OR @ToDate IS NULL)
         
					   UNION ALL
            SELECT 'EXTRA FUND RECEIVED FROM ADMIN' Type, 
                   'CLOSING DAILY' Description, 
                   ISNULL(COUNT(*), 0) Transactions, 
                   ISNULL(SUM(ABS(T.Usd)), 0) Usd
            FROM dbo.ExtraFund T
               
            WHERE T.AgencyId = @agencyId
			AND (T.CashAdmin = 0 AND T.IsCashier = 0)
                  AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                       OR @FromDate IS NULL)
                  AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                       OR @ToDate IS NULL)
        
            -- PHONE SALES 10
			 UNION ALL
            SELECT 'PHONE SALES' Type, 
                   'CLOSING DAILY' Description, 
                   ISNULL(COUNT(*), 0) Transactions, 
                   SUM(T.CardPaymentFee) + SUM(T.SellingValue) + (ISNULL(SUM(T.SellingValue), 0) * (SUM(T.Tax) / COUNT(T.PhoneSalesId)) / 100) Usd
            --ISNULL(SUM(T.SellingValue) - SUM(T.PurchaseValue), 0) Usd
            FROM PhoneSales T
                 INNER JOIN Inventorybyagency I ON I.InventoryByAgencyId = T.InventoryByAgencyId
                 INNER JOIN Agencies A ON A.AgencyId = I.AgencyId
            WHERE A.AgencyId = @AgencyId
                  AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                       OR @FromDate IS NULL)
                  AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                       OR @ToDate IS NULL)
            --UNION ALL ya no existe
            ----HEADPHONES AND CHARGERS 11

            --SELECT 'HEADPHONES AND CHARGERS' Type, 
            --       'CLOSING DAILY' Description, 
            --       ISNULL(SUM(HeadphonesQuantity + ChargersQuantity), 0) Transactions, 
            --       ISNULL(SUM(T.HeadphonesUsd + ChargersUsd), 0) Usd
            --FROM HeadphonesAndChargers T
            --WHERE t.AgencyId = @AgencyId
            --      AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
            --           OR @FromDate IS NULL)
            --      AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
            --           OR @ToDate IS NULL)
            --VENTRA 12
            UNION ALL
            SELECT 'VENTRA' Type, 
                   'CLOSING DAILY' Description, 
                   ISNULL(SUM(ReloadQuantity), 0) Transactions, 
                   ISNULL(SUM(T.ReloadUsd), 0) Usd
            FROM Ventra T
            WHERE t.AgencyId = @AgencyId
                  AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                       OR @FromDate IS NULL)
                  AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                       OR @ToDate IS NULL)
            UNION ALL
            --PHONE CARDS

            SELECT 'PHONE CARDS' Type, 
                   'CLOSING DAILY' Description, 
                   ISNULL(SUM(Quantity), 0) Transactions, 
                   ISNULL(SUM(T.PhoneCardsUsd), 0) Usd
            FROM PhoneCards T
            WHERE t.AgencyId = @AgencyId
                  AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                       OR @FromDate IS NULL)
                  AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                       OR @ToDate IS NULL)
            UNION ALL
            --Notary 14

            SELECT 'NOTARY' Type, 
                   'CLOSING DAILY' Description, 
                   ISNULL(SUM(Quantity), 0) Transactions, 
                   ISNULL(SUM(T.Usd), 0) Usd
            FROM Notary T
            WHERE T.AgencyId = @AgencyId
                  AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                       OR @FromDate IS NULL)
                  AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                       OR @ToDate IS NULL)
            UNION ALL
            SELECT 'DISCOUNTS' Type, 
                   'CLOSING DAILY' Description, 
                   ISNULL(SUM(Transactions), 0) Transactions, 
                   ISNULL(SUM(Usd), 0) Usd
            FROM
            (
                SELECT 'DiscountMoneyTransfers' Type, 
                       'CLOSING DAILY' Description, 
                       COUNT(*) Transactions, 
                       SUM(ABS(S.Discount)) Usd
                FROM DiscountMoneyTransfers S
                     INNER JOIN Agencies A ON A.AgencyId = S.AgencyId
                WHERE A.AgencyId = @AgencyId
                      AND CAST(S.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                      AND CAST(S.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                UNION ALL
                SELECT 'DiscountChecks' Type, 
                       'CLOSING DAILY' Description, 
                       COUNT(*) Transactions, 
                       SUM(ABS(C.Discount)) Usd
                FROM DiscountChecks C
                     INNER JOIN Agencies A ON A.AgencyId = C.AgencyId
                WHERE A.AgencyId = @AgencyId
                      AND CAST(C.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                      AND CAST(C.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                UNION ALL
                SELECT 'DiscountPhones' Type, 
                       'CLOSING DAILY' Description, 
                       COUNT(*) Transactions, 
                       SUM(ABS(P.Discount)) Usd
                FROM DiscountPhones P
                     INNER JOIN Agencies A ON A.AgencyId = P.AgencyId
                WHERE A.AgencyId = @AgencyId
                      AND CAST(P.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                      AND CAST(P.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                GROUP BY P.AgencyId, 
                         CAST(P.CreationDate AS DATE)
                UNION ALL
                SELECT 'DiscountTitles' Type, 
                       'CLOSING DAILY' Description, 
                       COUNT(*) Transactions, 
                       SUM(ABS(T.Discount)) Usd
                FROM DiscountTitles T
                     INNER JOIN Agencies A ON A.AgencyId = T.AgencyId
                WHERE A.AgencyId = @AgencyId
                      AND CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                      AND CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                GROUP BY T.AgencyId, 
                         CAST(T.CreationDate AS DATE)
                UNION ALL
                SELECT 'DiscountCityStickers' Type, 
                       'CLOSING DAILY' Description, 
                       COUNT(*) Transactions, 
                       SUM(ABS(C.Usd)) Usd
                FROM DiscountCityStickers C
                     INNER JOIN Agencies A ON A.AgencyId = C.AgencyId
                WHERE A.AgencyId = @AgencyId
                      AND CAST(C.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                      AND CAST(C.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                GROUP BY C.AgencyId, 
                         CAST(C.CreationDate AS DATE)
                UNION ALL
                SELECT 'DiscountPlateStickers' Type, 
                       'CLOSING DAILY' Description, 
                       COUNT(*) Transactions, 
                       SUM(ABS(l.Usd)) Usd
                FROM DiscountPlateStickers L
                     INNER JOIN Agencies A ON A.AgencyId = L.AgencyId
                WHERE A.AgencyId = @AgencyId
                      AND CAST(L.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                      AND CAST(L.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                GROUP BY L.AgencyId, 
                         CAST(L.CreationDate AS DATE)
                UNION ALL
                SELECT 'PromotionalCodes' Type, 
                       'CLOSING DAILY' Description, 
                       COUNT(*) Transactions, 
                       SUM(pc.Usd) Usd
                FROM PromotionalCodes pc
                     INNER JOIN PromotionalCodesStatus Pt ON pc.PromotionalCodeId = pt.PromotionalCodeId
                WHERE pt.AgencyUsedId = @agencyId
                      AND CAST(PT.UsedDate AS DATE) >= CAST(@FromDate AS DATE)
                      AND CAST(PT.UsedDate AS DATE) <= CAST(@ToDate AS DATE)
                GROUP BY pt.AgencyUsedId
            ) AS Discounts
            UNION ALL
            SELECT 'OTHER' Type, 
                   'CLOSING DAILY' Description, 
                   ISNULL(COUNT(*), 0) Transactions, 
                   ISNULL(SUM(T.Usd), 0) Usd
            FROM dbo.OthersDetails T
            WHERE T.AgencyId = @agencyId
                  AND CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                  AND CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
           
            UNION ALL
            SELECT 'EXPENSES' Type, 
                   'CLOSING DAILY' Description, 
                   ISNULL(COUNT(*), 0) Transactions, 
                   ISNULL(SUM(ABS(T.Usd)), 0) Usd
            FROM dbo.EXPENSES T
            WHERE T.AgencyId = @agencyId
                  AND CAST(T.CreatedOn AS DATE) >= CAST(@FromDate AS DATE)
                  AND CAST(T.CreatedOn AS DATE) <= CAST(@ToDate AS DATE)
            UNION ALL
            SELECT 'OTHER PAYMENT' Type, 
                   'CLOSING DAILY' Description, 
                   ISNULL(COUNT(*), 0) Transactions, 
                  ISNULL(SUM(T.Usd), 0) + isnull(sum(t.UsdPayMissing), 0) Usd
            FROM dbo.OtherPayments T
            WHERE T.AgencyId = @agencyId
                
                  AND CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                  AND CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
            --UNION ALL
           
            --SELECT 'RENT PAYMENTS AND DEPOSITS' Type, 
            --       'CLOSING DAILY' Description, 
            --       Query.RentPaymentsTransactions + Query.DepositPaymentsTransactions + Query.FeeDueTransactions + Query.DepositRefundsTransactions Transactions, 
            --       ISNULL((QUERY.RentPayments + QUERY.DepositPayments + QUERY.FeeDue) - QUERY.DepositRefunds, 0) AS Usd
            --FROM
            --(
            --    SELECT ISNULL(
            --    (
            --        SELECT SUM(ISNULL(RP.Usd, 0)) Usd
            --            FROM RentPayments RP
            --             INNER JOIN Agencies a ON RP.AgencyId = a.AgencyId
            --             INNER JOIN Users u ON RP.CreatedBy = u.UserId
            --        WHERE RP.AgencyId = @AgencyId
            --              AND CAST(RP.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
            --              AND CAST(RP.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
            --    ), 0) RentPayments, 
            --           ISNULL(
            --    (
            --        SELECT ISNULL(COUNT(*), 0) Transactions
            --        FROM RentPayments RP
            --             INNER JOIN Agencies a ON RP.AgencyId = a.AgencyId
            --             INNER JOIN Users u ON RP.CreatedBy = u.UserId
            --        WHERE RP.AgencyId = @AgencyId
            --              AND CAST(RP.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
            --              AND CAST(RP.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
            --    ), 0) RentPaymentsTransactions, 
            --           ISNULL(
            --    (
            --        SELECT SUM(ISNULL(DP.Usd, 0)) Usd
            --        FROM DepositFinancingPayments DP
            --             INNER JOIN Agencies a ON DP.AgencyId = a.AgencyId
            --             INNER JOIN Users u ON DP.CreatedBy = u.UserId
            --        WHERE dp.AgencyId = @AgencyId
            --              AND CAST(dp.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
            --              AND CAST(dp.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
            --    ), 0) DepositPayments, 
            --           ISNULL(
            --    (
            --        SELECT ISNULL(COUNT(*), 0) Transactions
            --        FROM DepositFinancingPayments DP
            --             INNER JOIN Agencies a ON DP.AgencyId = a.AgencyId
            --             INNER JOIN Users u ON DP.CreatedBy = u.UserId
            --        WHERE dp.AgencyId = @AgencyId
            --              AND CAST(dp.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
            --              AND CAST(dp.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
            --    ), 0) DepositPaymentsTransactions, 
            --           ISNULL(
            --    (
            --        SELECT SUM(ISNULL(c.RefundUsd, 0)) Usd
            --        FROM Contract c
            --             INNER JOIN Agencies a ON c.AgencyId = a.AgencyId
            --             INNER JOIN Users u ON c.CreatedBy = u.UserId
            --        WHERE c.AgencyRefundId = @AgencyId
            --              AND CAST(c.RefundDate AS DATE) >= CAST(@FromDate AS DATE)
            --              AND CAST(c.RefundDate AS DATE) <= CAST(@ToDate AS DATE)
            --    ), 0) DepositRefunds, 
            --           ISNULL(
            --    (
            --        SELECT ISNULL(COUNT(*), 0) Transactions
            --        FROM Contract c
            --             INNER JOIN Agencies a ON c.AgencyId = a.AgencyId
            --             INNER JOIN Users u ON c.CreatedBy = u.UserId
            --        WHERE c.AgencyRefundId = @AgencyId
            --              AND CAST(c.RefundDate AS DATE) >= CAST(@FromDate AS DATE)
            --              AND CAST(c.RefundDate AS DATE) <= CAST(@ToDate AS DATE)
            --    ), 0) DepositRefundsTransactions, 
            --           ISNULL(
            --    (
            --        SELECT SUM(ISNULL(RP.FeeDue, 0)) Usd
            --        FROM RentPayments RP
            --             INNER JOIN Agencies a ON RP.AgencyId = a.AgencyId
            --             INNER JOIN Users u ON RP.CreatedBy = u.UserId
            --        WHERE RP.AgencyId = @AgencyId
            --              AND CAST(RP.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
            --              AND CAST(RP.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
            --    ), 0) FeeDue, 
            --           ISNULL(
            --    (
            --        SELECT ISNULL(COUNT(*), 0) Transactions
            --        FROM RentPayments RP
            --             INNER JOIN Agencies a ON RP.AgencyId = a.AgencyId
            --             INNER JOIN Users u ON RP.CreatedBy = u.UserId
            --        WHERE RP.AgencyId = @AgencyId
            --              AND CAST(RP.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
            --              AND CAST(RP.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
            --    ), 0) FeeDueTransactions
            --) QUERY
        ) QueryFinal
        WHERE Transactions > 0;
    END;
GO