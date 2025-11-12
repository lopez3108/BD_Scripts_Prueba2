SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetReportDailySalesCashiers]
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
         SELECT Type =ISNULL(QF.Type, 0),
		 Cashier = ISNULL(QF.Cashier, ''),
                UserId = ISNULL(QF.UserId, 0),
                Transactions = ISNULL(SUM(Transactions), 0),
                Usd = ISNULL(SUM(Usd), 0)
         FROM
         (
		         SELECT 'BILL PAYMENT' Type, 
                   UPPER(U.Name) Cashier, 
                   U.UserId, 
                   ISNULL(COUNT(*), 0) Transactions, 
                   ISNULL(SUM(ABS(T.Usd)), 0) Usd
            FROM dbo.BillPayments T
                 INNER JOIN Users u ON T.CreatedBy = u.UserId
            WHERE T.AgencyId = @agencyId
                  AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                       OR @FromDate IS NULL)
                  AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                       OR @ToDate IS NULL)
            GROUP BY U.Name, 
                     U.UserId
            UNION ALL

	    --MONEY TRANSFER 1

             SELECT 'MONEY TRANSFER' Type,
                    UPPER(U.Name) Cashier,
                    U.UserId,
                    ISNULL(SUM(T.Transactions), 0) Transactions,
                    ISNULL(SUM(T.Usd), 0) Usd
             FROM MoneyTransfers T
                  INNER JOIN Users u ON T.CreatedBy = u.UserId
             WHERE T.AgencyId = @AgencyId
                   AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                        OR @FromDate IS NULL)
                   AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                        OR @ToDate IS NULL)
             GROUP BY U.Name,
                      U.UserId
					    UNION ALL
            --MONEY TRANSFER M.O
            SELECT 'MONEY TRANSFER (M.O) ' Type, 
                      UPPER(U.Name) Cashier,
                    U.UserId,
                   SUM(ISNULL(T.TransactionsNumberMoneyOrders, 0)) Transactions, 
                   SUM(ISNULL(T.UsdMoneyOrders, 0)) AS Usd
            FROM MoneyTransfers T
			INNER JOIN Users u ON T.CreatedBy = u.UserId
            WHERE T.AgencyId = @AgencyId
                  AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                       OR @FromDate IS NULL)
                  AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                       OR @ToDate IS NULL)
					    GROUP BY U.Name,
                      U.UserId
					    
             UNION ALL

	    --PAYROLL CHECK 2

             SELECT 'PAYROLL CHECK' Type,
                    UPPER(U.Name) Cashier,
                    U.UserId,
                    ISNULL(COUNT(*), 0) Transactions,
                    ISNULL(SUM(T.Amount), 0) Usd
             FROM ChecksEls T
                  INNER JOIN ProviderTypes p ON t.ProviderTypeId = p.ProviderTypeId
                  INNER JOIN Users u ON T.CreatedBy = u.UserId
             WHERE P.Code = 'C03'
                   AND T.AgencyId = @AgencyId
                   AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                        OR @FromDate IS NULL)
                   AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                        OR @ToDate IS NULL)
             GROUP BY U.Name,
                      U.UserId
             UNION ALL
	    
	    --TAX CHECK 3

             SELECT 'TAX CHECK' Type,
                    UPPER(U.Name) Cashier,
                    U.UserId,
                    ISNULL(COUNT(*), 0) Transactions,
                    ISNULL(SUM(T.Amount), 0) Usd
             FROM ChecksEls T
                  INNER JOIN ProviderTypes p ON t.ProviderTypeId = p.ProviderTypeId
                  INNER JOIN Users u ON T.CreatedBy = u.UserId
             WHERE P.Code = 'C04'
                   AND T.AgencyId = @AgencyId
                   AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                        OR @FromDate IS NULL)
                   AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                        OR @ToDate IS NULL)
             GROUP BY U.Name,
                      U.UserId
      UNION ALL
            --CANCELLATIONS 4
            SELECT  'CANCELLATIONS' Type,

                   q.Cashier, 
				   q.UserId,
                   ISNULL(SUM(Q.Transactions), 0) Transactions, 
                   ISNULL(SUM(Q.Usd), 0)
            FROM
            (
                SELECT 'CANCELLATIONS' Type, 
                       UPPER(U.Name) Cashier, 
                       U.UserId, 
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
                     INNER JOIN Users u ON T.CreatedBy = u.UserId
                WHERE t.AgencyId = @AgencyId
                      AND ((CAST(t.RefundDate AS DATE) >= CAST(@FromDate AS DATE)
                            AND CAST(t.RefundDate AS DATE) <= CAST(@ToDate AS DATE))
                           OR (CAST(t.NewTransactionDate AS DATE) >= CAST(@FromDate AS DATE)
                               AND CAST(t.NewTransactionDate AS DATE) <= CAST(@ToDate AS DATE)))
                GROUP BY CAST(t.RefundDate AS DATE), 
                         CAST(t.NewTransactionDate AS DATE), 
                         t.RefundFee, 
                         t.AgencyId, 
                         u.Name, 
                         u.UserId
            ) Q
            GROUP BY  
                     q.Cashier, 
                     q.UserId
            UNION ALL
            
            SELECT 'RETURN CHECK' Type, 
                   UPPER(U.Name) Cashier, 
                   U.UserId, 
                   ISNULL(COUNT(*), 0) Transactions, 
                   ISNULL(SUM(T.Usd + T.ProviderFee), 0) Usd
            FROM dbo.ReturnedCheck T
                 INNER JOIN Users u ON T.CreatedBy = u.UserId
            WHERE T.ReturnedAgencyId = @AgencyId
                  AND (CAST(T.ReturnDate AS DATE) >= CAST(@FromDate AS DATE)
                       OR @FromDate IS NULL)
                  AND (CAST(T.ReturnDate AS DATE) <= CAST(@ToDate AS DATE)
                       OR @ToDate IS NULL)
					   GROUP BY U.Name, 
                     U.UserId
            UNION ALL
            SELECT 'RETURN CHECK PAYMENTS' Type, 
                   UPPER(U.Name) Cashier, 
                   U.UserId, 
                   ISNULL(COUNT(*), 0) Transactions, 
                   ISNULL(SUM(T.Usd), 0) Usd
            FROM ProviderTypes PT
                 INNER JOIN Providers P ON PT.ProviderTypeId = p.ProviderTypeId
                 INNER JOIN dbo.ReturnedCheck rc ON rc.ProviderId = p.ProviderId
                 INNER JOIN ReturnPayments T ON t.ReturnedCheckId = rc.ReturnedCheckId
                 INNER JOIN Users u ON T.CreatedBy = u.UserId
            WHERE PT.CODE = 'C02'
                  AND T.AgencyId = @AgencyId
                  AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                       OR @FromDate IS NULL)
                  AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                       OR @ToDate IS NULL)
					   GROUP BY U.Name, 
                     U.UserId
            UNION ALL
             SELECT 'VEHICLE SERVICES' Type,
                    Cashier,
                    UserId,
                    ISNULL(SUM(Transactions), 0) Transactions,
                    ISNULL(SUM(Usd), 0) Usd
             FROM
             (
                 SELECT 'CitySticker' Type,
                        UPPER(U.Name) Cashier,
                        U.UserId,
                        COUNT(*) Transactions,
                        SUM(T.Usd + t.Fee1 + t.FeeEls + t.CardPaymentFee) Usd
                 FROM CityStickers T
                      INNER JOIN Users u ON T.CreatedBy = u.UserId
                 WHERE T.AgencyId = @AgencyId
                       AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                            OR @FromDate IS NULL)
                       AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                            OR @ToDate IS NULL)
                 GROUP BY U.Name,
                          U.UserId
                 UNION ALL
                 SELECT 'CountyTaxes' Type,
                        UPPER(U.Name) Cashier,
                        U.UserId,
                        COUNT(*) Transactions,
                        SUM(T.Usd + t.Fee1 + t.FeeEls + t.CardPaymentFee) Usd
                 FROM CountryTaxes T
                      INNER JOIN Users u ON T.CreatedBy = u.UserId
                 WHERE T.AgencyId = @AgencyId
                       AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                            OR @FromDate IS NULL)
                       AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                            OR @ToDate IS NULL)
                 GROUP BY U.Name,
                          U.UserId
                 UNION ALL
                 SELECT 'ParkingTicketsCards' Type,
                        UPPER(U.Name) Cashier,
                        U.UserId,
                        COUNT(*) Transactions,
                        SUM(T.Usd + t.Fee1 + t.Fee2 + t.CardPaymentFee) Usd
                 FROM ParkingTicketsCards T
                      INNER JOIN Users u ON T.CreatedBy = u.UserId
                 WHERE T.AgencyId = @AgencyId
                       AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                            OR @FromDate IS NULL)
                       AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                            OR @ToDate IS NULL)
                 GROUP BY U.Name,
                          U.UserId
                 UNION ALL
                 SELECT 'PlateStickers' Type,
                        UPPER(U.Name) Cashier,
                        U.UserId,
                        COUNT(*) Transactions,
                        SUM(T.Usd + t.Fee1 + T.FeeEls + t.CardPaymentFee) Usd
                 FROM PlateStickers T
                      INNER JOIN Users u ON T.CreatedBy = u.UserId
                 WHERE T.AgencyId = @AgencyId
                       AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                            OR @FromDate IS NULL)
                       AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                            OR @ToDate IS NULL)
                 GROUP BY U.Name,
                          U.UserId
                 UNION ALL
                 SELECT 'RunnerServices' Type,
                        UPPER(U.Name) Cashier,
                        U.UserId,
                        SUM(t.NumberTransactions) Transactions,
                        SUM(T.Usd + T.FeeEls) Usd
                 FROM RunnerServices t
                      INNER JOIN Users u ON T.CreatedBy = u.UserId
                 WHERE T.AgencyId = @AgencyId
                       AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                            OR @FromDate IS NULL)
                       AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                            OR @ToDate IS NULL)
                 GROUP BY U.Name,
                          U.UserId
                 UNION ALL
                 SELECT 'TitleInquiry' Type,
                        UPPER(U.Name) Cashier,
                        U.UserId,
                        COUNT(*) Transactions,
                        SUM(T.Usd + t.Fee1 + T.FeeEls + t.CardPaymentFee) Usd
                 FROM TitleInquiry T
                      INNER JOIN Users u ON T.CreatedBy = u.UserId
                 WHERE T.AgencyId = @AgencyId
                       AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                            OR @FromDate IS NULL)
                       AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                            OR @ToDate IS NULL)
                 GROUP BY U.Name,
                          U.UserId
                 UNION ALL
                 SELECT 'Titles' Type,
                        UPPER(U.Name) Cashier,
                        U.UserId,
                        COUNT(*) Transactions,
                        SUM(T.Usd + t.Fee1 + T.FeeEls + t.CardPaymentFee) Usd
                 FROM Titles T
                      INNER JOIN Users u ON T.CreatedBy = u.UserId
                 WHERE T.ProcessAuto = 1
                       AND T.AgencyId = @AgencyId
                       AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                            OR @FromDate IS NULL)
                       AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                            OR @ToDate IS NULL)
                 GROUP BY U.Name,
                          U.UserId
 UNION ALL
                SELECT 'TRP' Type, 
                       UPPER(U.Name) Cashier, 
                       U.UserId, 
                       ISNULL(COUNT(*), 0) Transactions, 
                       SUM(T.Usd + t.Fee1 + T.TrpFee) Usd
                FROM TRP T
                     INNER JOIN Users u ON T.CreatedBy = u.UserId
                WHERE T.AgencyId = @AgencyId
                      AND (CAST(T.CreatedOn AS DATE) >= CAST(@FromDate AS DATE)
                           OR @FromDate IS NULL)
                      AND (CAST(T.CreatedOn AS DATE) <= CAST(@ToDate AS DATE)
                           OR @ToDate IS NULL)
                GROUP BY U.Name, 
                         U.UserId
             ) AS Els
             GROUP BY Cashier,
                      UserId
             --UNION ALL
             --SELECT 'ELS MANUAL' Type,
             --       UPPER(U.Name) Cashier,
             --       U.UserId,
             --       ISNULL(COUNT(*), 0) Transactions,
             --       ISNULL(SUM(T.Usd + ISNULL(t.Fee1, 0) + ISNULL(T.FeeEls, 0) + ABS(ISNULL(t.FeeILDOR, 0)) + ABS(ISNULL(t.FeeILSOS, 0)) + ABS(ISNULL(t.FeeOther, 0))), 0) Usd
             --FROM Titles T
             --     INNER JOIN Users u ON T.CreatedBy = u.UserId
             --WHERE T.ProcessAuto = 0
             --      AND T.AgencyId = @AgencyId
             --      AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
             --           OR @FromDate IS NULL)
             --      AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
             --           OR @ToDate IS NULL)
             --GROUP BY U.Name,
             --         U.UserId
	--TICKETS 
             UNION ALL
             SELECT 'TRAFFIC TICKETS' Type,
                    Cashier,
                    UserId,
                    ISNULL(SUM(Transactions), 0) Transactions,
                    ISNULL(SUM(Usd), 0) Usd
             FROM
             (
                 SELECT 'FEE SERVICES' Type,
                        UPPER(U.Name) Cashier,
                        U.UserId,
                        ISNULL(COUNT(*), 0) Transactions,
                        ISNULL(SUM(t.Usd), 0) Usd
                 FROM TicketFeeServices t
                      INNER JOIN Users u ON T.CreatedBy = u.UserId
                 WHERE t.AgencyId = @AgencyId
                       AND CAST(t.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                       AND CAST(t.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                 GROUP BY U.Name,
                          U.UserId
                 UNION ALL
                 SELECT 'TICKETS' Type,
                        UPPER(U.Name) Cashier,
                        U.UserId,
                        ISNULL(COUNT(*), 0) Transactions,
                        ISNULL(SUM(ISNULL(t.MoneyOrderFee, 0)) + SUM(t.Usd), 0) Usd
                 FROM Tickets t
                      INNER JOIN Users u ON T.CreatedBy = u.UserId
                 WHERE t.UpdateToPendingDate IS NOT NULL
                       AND t.ChangedToPendingByAgency = @AgencyId
                       AND CAST(t.UpdateToPendingDate AS DATE) >= CAST(@FromDate AS DATE)
                       AND CAST(t.UpdateToPendingDate AS DATE) <= CAST(@ToDate AS DATE)
                 GROUP BY U.Name,
                          U.UserId
             ) QueryTickets
             GROUP BY Cashier,
                      UserId
					 

					 	   UNION ALL
            SELECT 'EXTRA FUND RECEIVED FROM CASHIER' Type, 
                   UPPER(U.Name) Cashier, 
                   U.UserId, 
                   ISNULL(COUNT(*), 0) Transactions, 
                   ISNULL(SUM(ABS(T.Usd)), 0) Usd
            FROM dbo.ExtraFund T
                 INNER JOIN Users u ON T.CreatedBy = u.UserId
            WHERE T.AgencyId = @agencyId
			AND ((T.CashAdmin = 0 AND T.IsCashier = 1) OR (T.CashAdmin = 1 AND T.IsCashier = 0))
                  AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                       OR @FromDate IS NULL)
                  AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                       OR @ToDate IS NULL)
            GROUP BY U.Name, 
                     U.UserId
					   UNION ALL
            SELECT 'EXTRA FUND RECEIVED FROM ADMIN' Type, 
                   UPPER(U.Name) Cashier, 
                   U.UserId, 
                   ISNULL(COUNT(*), 0) Transactions, 
                   ISNULL(SUM(ABS(T.Usd)), 0) Usd
            FROM dbo.ExtraFund T
                 INNER JOIN Users u ON T.CreatedBy = u.UserId
            WHERE T.AgencyId = @agencyId
			AND (T.CashAdmin = 0 AND T.IsCashier = 0)
                  AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                       OR @FromDate IS NULL)
                  AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                       OR @ToDate IS NULL)
            GROUP BY U.Name, 
                     U.UserId
             UNION ALL

	     	-- PHONE SALES 10

             SELECT 'PHONE SALES' Type,
                    UPPER(U.Name) Cashier,
                    U.UserId,
                    ISNULL(COUNT(*), 0) Transactions,
                    SUM(T.CardPaymentFee) + SUM(T.SellingValue) + (ISNULL(SUM(T.SellingValue), 0) * (SUM(T.Tax) / COUNT(T.PhoneSalesId)) / 100) Usd
             FROM PhoneSales T
                  INNER JOIN Users u ON T.CreatedBy = u.UserId
                  INNER JOIN Inventorybyagency I ON I.InventoryByAgencyId = T.InventoryByAgencyId
                  INNER JOIN Agencies A ON A.AgencyId = I.AgencyId
             WHERE A.AgencyId = @AgencyId
                   AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                        OR @FromDate IS NULL)
                   AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                        OR @ToDate IS NULL)
             GROUP BY U.Name,
                      U.UserId
             UNION ALL
	    --HEADPHONES AND CHARGERS 11

             SELECT 'HEADPHONES AND CHARGERS' Type,
                    UPPER(U.Name) Cashier,
                    U.UserId,
                    ISNULL(SUM(HeadphonesQuantity + ChargersQuantity), 0) Transactions,
                    ISNULL(SUM(T.HeadphonesUsd + ChargersUsd), 0) Usd
             FROM HeadphonesAndChargers T
                  INNER JOIN Users u ON T.CreatedBy = u.UserId
             WHERE t.AgencyId = @AgencyId
                   AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                        OR @FromDate IS NULL)
                   AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                        OR @ToDate IS NULL)
             GROUP BY U.Name,
                      U.UserId
         --VENTRA 12
             UNION ALL
             SELECT 'VENTRA' Type,
                    UPPER(U.Name) Cashier,
                    U.UserId,
                    ISNULL(SUM(ReloadQuantity), 0) Transactions,
                    ISNULL(SUM(T.ReloadUsd), 0) Usd
             FROM Ventra T
                  INNER JOIN Users u ON T.CreatedBy = u.UserId
             WHERE t.AgencyId = @AgencyId
                   AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                        OR @FromDate IS NULL)
                   AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                        OR @ToDate IS NULL)
             GROUP BY U.Name,
                      U.UserId
             UNION ALL
	    --PHONE CARDS

             SELECT 'PHONE CARDS' Type,
                    UPPER(U.Name) Cashier,
                    U.UserId,
                    ISNULL(SUM(Quantity), 0) Transactions,
                    ISNULL(SUM(T.PhoneCardsUsd), 0) Usd
             FROM PhoneCards T
                  INNER JOIN Users u ON T.CreatedBy = u.UserId
             WHERE t.AgencyId = @AgencyId
                   AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                        OR @FromDate IS NULL)
                   AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                        OR @ToDate IS NULL)
             GROUP BY U.Name,
                      U.UserId
             UNION ALL
	    --Notary 14

             SELECT 'NOTARY' Type,
                    UPPER(U.Name) Cashier,
                    U.UserId,
                    isnull(SUM(Quantity), 0) Transactions,
                    ISNULL(SUM(T.Usd), 0) Usd
             FROM Notary T
                  INNER JOIN Users u ON T.CreatedBy = u.UserId
             WHERE T.AgencyId = @AgencyId
                   AND (CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                        OR @FromDate IS NULL)
                   AND (CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                        OR @ToDate IS NULL)
             GROUP BY U.Name,
                      U.UserId
             UNION ALL
             SELECT 'DISCOUNTS' Type,
                    Cashier,
                    UserId,
                    ISNULL(SUM(Transactions), 0) Transactions,
                    ISNULL(SUM(Usd), 0) Usd
             FROM
             (
                 SELECT 'DiscountMoneyTransfers' Type,
                        UPPER(U.Name) Cashier,
                        U.UserId,
                        COUNT(*) Transactions,
                        SUM(ABS(S.Discount)) Usd
                 FROM DiscountMoneyTransfers S
                      INNER JOIN Users u ON S.CreatedBy = u.UserId
                      INNER JOIN Agencies A ON A.AgencyId = S.AgencyId
                 WHERE A.AgencyId = @AgencyId
                       AND CAST(S.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                       AND CAST(S.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                 GROUP BY U.Name,
                          U.UserId
                 UNION ALL
                 SELECT 'DiscountChecks' Type,
                        UPPER(U.Name) Cashier,
                        U.UserId,
                        COUNT(*) Transactions,
                        SUM(ABS(C.Discount)) Usd
                 FROM DiscountChecks C
                      INNER JOIN Users u ON C.CreatedBy = u.UserId
                      INNER JOIN Agencies A ON A.AgencyId = C.AgencyId
                 WHERE A.AgencyId = @AgencyId
                       AND CAST(C.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                       AND CAST(C.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                 GROUP BY U.Name,
                          U.UserId
                 UNION ALL
                 SELECT 'DiscountPhones' Type,
                        UPPER(U.Name) Cashier,
                        U.UserId,
                        COUNT(*) Transactions,
                        SUM(ABS(P.Discount)) Usd
                 FROM DiscountPhones P
                      INNER JOIN Users u ON P.CreatedBy = u.UserId
                      INNER JOIN Agencies A ON A.AgencyId = P.AgencyId
                 WHERE A.AgencyId = @AgencyId
                       AND CAST(P.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                       AND CAST(P.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                 GROUP BY U.Name,
                          U.UserId
                 UNION ALL
                 SELECT 'DiscountTitles' Type,
                        UPPER(U.Name) Cashier,
                        U.UserId,
                        COUNT(*) Transactions,
                        SUM(ABS(T.Discount)) Usd
                 FROM DiscountTitles T
                      INNER JOIN Users u ON T.CreatedBy = u.UserId
                      INNER JOIN Agencies A ON A.AgencyId = T.AgencyId
                 WHERE A.AgencyId = @AgencyId
                       AND CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                       AND CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                 GROUP BY U.Name,
                          U.UserId
                 UNION ALL
                 SELECT 'DiscountCityStickers' Type,
                        UPPER(U.Name) Cashier,
                        U.UserId,
                        COUNT(*) Transactions,
                        SUM(ABS(C.Usd)) Usd
                 FROM DiscountCityStickers C
                      INNER JOIN Users u ON C.CreatedBy = u.UserId
                      INNER JOIN Agencies A ON A.AgencyId = C.AgencyId
                 WHERE A.AgencyId = @AgencyId
                       AND CAST(C.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                       AND CAST(C.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                 GROUP BY U.Name,
                          U.UserId
                 UNION ALL
                 SELECT 'DiscountPlateStickers' Type,
                        UPPER(U.Name) Cashier,
                        U.UserId,
                        COUNT(*) Transactions,
                        SUM(ABS(l.Usd)) Usd
                 FROM DiscountPlateStickers L
                      INNER JOIN Users u ON L.CreatedBy = u.UserId
                      INNER JOIN Agencies A ON A.AgencyId = L.AgencyId
                 WHERE A.AgencyId = @AgencyId
                       AND CAST(L.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                       AND CAST(L.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
                 GROUP BY U.Name,
                          U.UserId
                 UNION ALL
                 SELECT 'PromotionalCodes' Type,
                        UPPER(U.Name) Cashier,
                        U.UserId,
                        COUNT(*) Transactions,
                        SUM(pc.Usd) Usd
                 FROM PromotionalCodes pc
                      INNER JOIN PromotionalCodesStatus Pt ON pc.PromotionalCodeId = pt.PromotionalCodeId
                      INNER JOIN Users u ON Pt.UserUsedId = u.UserId
                 WHERE pt.AgencyUsedId = @agencyId
                       AND CAST(PT.UsedDate AS DATE) >= CAST(@FromDate AS DATE)
                       AND CAST(PT.UsedDate AS DATE) <= CAST(@ToDate AS DATE)
                 GROUP BY pt.AgencyUsedId,
                          U.Name,
                          U.UserId
             ) AS Discounts
             GROUP BY UserId,
                      Cashier
             UNION ALL
             SELECT 'OTHER' Type,
                    UPPER(U.Name) Cashier,
                    U.UserId,
                    ISNULL(COUNT(*), 0) Transactions,
                    ISNULL(SUM(T.Usd), 0) Usd
             FROM dbo.OthersDetails T
                  INNER JOIN Users u ON T.CreatedBy = u.UserId
             WHERE T.AgencyId = @agencyId
                   AND CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                   AND CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
             GROUP BY U.Name,
                      U.UserId
             UNION ALL
             SELECT 'EXPENSES' Type,
                    UPPER(U.Name) Cashier,
                    U.UserId,
                    ISNULL(COUNT(*), 0) Transactions,
                    ISNULL(SUM(ABS(T.Usd)), 0) Usd
             FROM dbo.EXPENSES T
                  INNER JOIN Users u ON T.CreatedBy = u.UserId
             WHERE T.AgencyId = @agencyId
                   AND CAST(T.CreatedOn AS DATE) >= CAST(@FromDate AS DATE)
                   AND CAST(T.CreatedOn AS DATE) <= CAST(@ToDate AS DATE)
             GROUP BY U.Name,
                      U.UserId
					     UNION ALL
            SELECT 'OTHER PAYMENT' Type, 
                   UPPER(U.Name) Cashier, 
                   U.UserId, 
                   ISNULL(COUNT(*), 0) Transactions, 
                   ISNULL(SUM(T.Usd), 0)+ isnull(sum(t.UsdPayMissing), 0) Usd
          FROM dbo.OtherPayments T
                 INNER JOIN Users u ON T.CreatedBy = u.UserId
            WHERE T.AgencyId = @agencyId
              
                  AND CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                  AND CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
            GROUP BY U.Name, 
                     U.UserId

					 --Union all
					 --SELECT 'RENT PAYMENTS AND DEPOSITS' Type, 
               
      --             Query.RentPaymentsTransactions + Query.DepositPaymentsTransactions + Query.FeeDueTransactions + Query.DepositRefundsTransactions Transactions, 
      --             ISNULL((QUERY.RentPayments + QUERY.DepositPayments + QUERY.FeeDue) - QUERY.DepositRefunds, 0) AS Usd
      --      FROM
      --      (
      --          SELECT ISNULL(
      --          (
      --              SELECT SUM(ISNULL(RP.Usd, 0)) Usd

      --                  FROM RentPayments RP
      --                   INNER JOIN Agencies a ON RP.AgencyId = a.AgencyId
      --                   INNER JOIN Users u ON RP.CreatedBy = u.UserId
      --              WHERE RP.AgencyId = @AgencyId
      --                    AND CAST(RP.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
      --                    AND CAST(RP.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
      --          ), 0) RentPayments, 
      --                 ISNULL(
      --          (
      --              SELECT ISNULL(COUNT(*), 0) Transactions
      --              FROM RentPayments RP
      --                   INNER JOIN Agencies a ON RP.AgencyId = a.AgencyId
      --                   INNER JOIN Users u ON RP.CreatedBy = u.UserId
      --              WHERE RP.AgencyId = @AgencyId
      --                    AND CAST(RP.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
      --                    AND CAST(RP.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
      --          ), 0) RentPaymentsTransactions, 
      --                 ISNULL(
      --          (
      --              SELECT SUM(ISNULL(DP.Usd, 0)) Usd
      --              FROM DepositFinancingPayments DP
      --                   INNER JOIN Agencies a ON DP.AgencyId = a.AgencyId
      --                   INNER JOIN Users u ON DP.CreatedBy = u.UserId
      --              WHERE dp.AgencyId = @AgencyId
      --                    AND CAST(dp.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
      --                    AND CAST(dp.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
      --          ), 0) DepositPayments, 
      --                 ISNULL(
      --          (
      --              SELECT ISNULL(COUNT(*), 0) Transactions
      --              FROM DepositFinancingPayments DP
      --                   INNER JOIN Agencies a ON DP.AgencyId = a.AgencyId
      --                   INNER JOIN Users u ON DP.CreatedBy = u.UserId
      --              WHERE dp.AgencyId = @AgencyId
      --                    AND CAST(dp.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
      --                    AND CAST(dp.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
      --          ), 0) DepositPaymentsTransactions, 
      --                 ISNULL(
      --          (
      --              SELECT SUM(ISNULL(c.RefundUsd, 0)) Usd
      --              FROM Contract c
      --                   INNER JOIN Agencies a ON c.AgencyId = a.AgencyId
      --                   INNER JOIN Users u ON c.CreatedBy = u.UserId
      --              WHERE c.AgencyRefundId = @AgencyId
      --                    AND CAST(c.RefundDate AS DATE) >= CAST(@FromDate AS DATE)
      --                    AND CAST(c.RefundDate AS DATE) <= CAST(@ToDate AS DATE)
      --          ), 0) DepositRefunds, 
      --                 ISNULL(
      --          (
      --              SELECT ISNULL(COUNT(*), 0) Transactions
      --              FROM Contract c
      --                   INNER JOIN Agencies a ON c.AgencyId = a.AgencyId
      --                   INNER JOIN Users u ON c.CreatedBy = u.UserId
      --              WHERE c.AgencyRefundId = @AgencyId
      --                    AND CAST(c.RefundDate AS DATE) >= CAST(@FromDate AS DATE)
      --                    AND CAST(c.RefundDate AS DATE) <= CAST(@ToDate AS DATE)
      --          ), 0) DepositRefundsTransactions, 
      --                 ISNULL(
      --          (
      --              SELECT SUM(ISNULL(RP.FeeDue, 0)) Usd
      --              FROM RentPayments RP
      --                   INNER JOIN Agencies a ON RP.AgencyId = a.AgencyId
      --                   INNER JOIN Users u ON RP.CreatedBy = u.UserId
      --              WHERE RP.AgencyId = @AgencyId
      --                    AND CAST(RP.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
      --                    AND CAST(RP.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
      --          ), 0) FeeDue, 
      --                 ISNULL(
      --          (
      --              SELECT ISNULL(COUNT(*), 0) Transactions
      --              FROM RentPayments RP
      --                   INNER JOIN Agencies a ON RP.AgencyId = a.AgencyId
      --                   INNER JOIN Users u ON RP.CreatedBy = u.UserId
      --              WHERE RP.AgencyId = @AgencyId
      --                    AND CAST(RP.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
      --                    AND CAST(RP.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
      --          ), 0) FeeDueTransactions
      --      ) QUERY
         ) AS QF
		
         --GROUP BY ROLLUP(QF.Cashier, QF.UserId);
         GROUP BY QF.Cashier,
                  QF.UserId,
				  qf.Type ORDER BY Type
				  ;

				 
     END;
GO