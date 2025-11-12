SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-06-26 DJ/5923: Excluce city stickers paid with card payment when they have parent title
-- 2024-09-02 DJ/6016: Include insurance operations
-- 20204-02-20 JT/5939: Para los tickets se agrupa la información por el Nuevo campo TransactionGuid

--date 2025-06-06 JF task 6574 Error en list card payments con discounts

CREATE PROCEDURE [dbo].[sp_GetSumCardPaymentsByAgencyId] @AgencyId INT,
@CreationDate DATE = NULL,
@UserId INT = NULL
AS
BEGIN
  DECLARE @CashierId INT = NULL;
  SET @CashierId = (SELECT
      CashierId
    FROM Cashiers
    WHERE UserId = @UserId)
  SELECT
    ISNULL(SUM(q.Suma), 0) Suma
   ,ISNULL(SUM(q.SumaFee), 0) SumaFee
   ,SUM(q.NumberTransactions) NumberTransactions
  FROM (SELECT
      --                    ISNULL(CAST(SUM(C.Usd) AS MONEY), 0) Suma,
      --                    ISNULL(CAST(SUM(C.Fee) AS MONEY), 0)  SumaFee,
      ISNULL(SUM(ISNULL(C.Usd, 0) + ISNULL(C.TotalPay, 0)), 0) Suma
     ,ISNULL(SUM(ISNULL(C.Fee, 0) + ISNULL(C.FeeUsd, 0)), 0) SumaFee
     ,SUM(C.NumberPayments) NumberTransactions

    FROM CardPayments C
    INNER JOIN Agencies a
      ON C.AgencyId = a.AgencyId
    INNER JOIN Users u
      ON C.CreatedBy = u.UserId
    WHERE C.AgencyId = @AgencyId
    AND (CAST(C.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
    OR @CreationDate IS NULL)
    AND (C.CreatedBy = @UserId
    OR @UserId IS NULL)
    UNION ALL
    SELECT
      ISNULL(SUM(ISNULL(C.USD, 0) - ISNULL(pc.USD, 0) + ISNULL(C.Fee1, 0)), 0) Suma
     ,ISNULL(SUM(C.CardPaymentFee), 0) SumaFee
     ,COUNT(*) NumberTransactions
    FROM Titles C
    INNER JOIN Agencies a
      ON C.AgencyId = a.AgencyId
    INNER JOIN Users u
      ON C.CreatedBy = u.UserId
    LEFT JOIN PromotionalCodesStatus Pt
      ON C.TitleId = Pt.TitleId
    LEFT JOIN PromotionalCodes pc
      ON Pt.PromotionalCodeId = pc.PromotionalCodeId
    WHERE C.AgencyId = @AgencyId
    AND (CAST(C.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
    OR @CreationDate IS NULL)
    AND C.CreatedBy = @UserId
    AND CardPayment = 1
    UNION ALL


    SELECT
      ISNULL(SUM(ISNULL(C.USD, 0) + ISNULL(C.LaminationFee, 0)), 0) Suma
     ,ISNULL(SUM(C.CardPaymentFee), 0) SumaFee
     ,COUNT(*) NumberTransactions
    FROM TRP C
    INNER JOIN Agencies a
      ON C.AgencyId = a.AgencyId
    INNER JOIN Users u
      ON C.CreatedBy = u.UserId
    WHERE C.AgencyId = @AgencyId
    AND (CAST(C.CreatedOn AS DATE) = CAST(@CreationDate AS DATE)
    OR @CreationDate IS NULL)
    AND C.CreatedBy = @UserId
    AND CardPayment = 1
    UNION ALL


    SELECT
      ISNULL(CAST(SUM(ISNULL(C.USD, 0) - ISNULL(pc.USD, 0) + ISNULL(C.Fee1, 0)) AS MONEY), 0) Suma
     ,ISNULL(CAST(SUM(C.CardPaymentFee) AS MONEY), 0) SumaFee
     ,COUNT(*) - ISNULL((SELECT
          COUNT(*)
        FROM dbo.CityStickers cs
        WHERE cs.AgencyId = @AgencyId --5923
        AND (CAST(cs.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
        OR @CreationDate IS NULL)
        AND cs.CreatedBy = @UserId
        AND cs.CardPayment = 1
        AND (cs.CardPayment = CAST(1 AS BIT)
        AND (cs.CardPaymentFee IS NULL
        OR cs.CardPaymentFee = 0)))
      , 0) AS NumberTransactions
    FROM CityStickers C
    INNER JOIN Agencies a
      ON C.AgencyId = a.AgencyId
    INNER JOIN Users u
      ON C.CreatedBy = u.UserId

 LEFT JOIN PromotionalCodesStatus Pt
      ON  C.CityStickerId = Pt.CityStickerId
    LEFT JOIN PromotionalCodes pc
      ON Pt.PromotionalCodeId = pc.PromotionalCodeId

    WHERE C.AgencyId = @AgencyId
    AND (CAST(C.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
    OR @CreationDate IS NULL)
    AND C.CreatedBy = @UserId
    AND CardPayment = 1



    UNION ALL
    SELECT
      ISNULL(CAST(SUM(ISNULL(C.USD, 0) - ISNULL(pc.USD, 0) + ISNULL(C.Fee1, 0)) AS MONEY), 0) Suma
     ,ISNULL(CAST(SUM(C.CardPaymentFee) AS MONEY), 0) SumaFee
     ,COUNT(*) NumberTransactions
    FROM PlateStickers C
    INNER JOIN Agencies a
      ON C.AgencyId = a.AgencyId
    INNER JOIN Users u
      ON C.CreatedBy = u.UserId
       LEFT JOIN PromotionalCodesStatus Pt
      ON   C.PlateStickerId = Pt.PlateStickerId
    LEFT JOIN PromotionalCodes pc
      ON Pt.PromotionalCodeId = pc.PromotionalCodeId

    WHERE C.AgencyId = @AgencyId
    AND (CAST(C.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
    OR @CreationDate IS NULL)
    AND (C.CreatedBy = @UserId
    OR @UserId IS NULL)
    AND CardPayment = 1


    UNION ALL
    SELECT
      ISNULL(CAST(SUM(ISNULL(C.USD, 0) + ISNULL(C.Fee1, 0)) AS MONEY), 0) Suma
     ,ISNULL(CAST(SUM(C.CardPaymentFee) AS MONEY), 0) SumaFee
     ,COUNT(*) NumberTransactions
    FROM TitleInquiry C
    INNER JOIN Agencies a
      ON C.AgencyId = a.AgencyId
    INNER JOIN Users u
      ON C.CreatedBy = u.UserId
    WHERE C.AgencyId = @AgencyId
    AND (CAST(C.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
    OR @CreationDate IS NULL)
    AND (C.CreatedBy = @UserId
    OR @UserId IS NULL)
    AND CardPayment = 1
    UNION ALL
    SELECT
      ISNULL(CAST(SUM(ISNULL(C.USD, 0) + ISNULL(C.Fee1, 0) + ISNULL(C.Fee2, 0)) AS MONEY), 0) Suma
     ,ISNULL(CAST(SUM(C.CardPaymentFee) AS MONEY), 0) SumaFee
     ,COUNT(*) NumberTransactions
    FROM ParkingTickets C
    INNER JOIN Agencies a
      ON C.AgencyId = a.AgencyId
    INNER JOIN Users u
      ON C.CreatedBy = u.UserId
    WHERE C.AgencyId = @AgencyId
    AND (CAST(C.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
    OR @CreationDate IS NULL)
    AND C.CreatedBy = @UserId
    AND CardPayment = 1
    UNION ALL
    SELECT
      ISNULL(CAST(SUM(ISNULL(C.USD, 0) + ISNULL(C.Fee1, 0)) AS MONEY), 0) Suma
     ,ISNULL(CAST(SUM(C.CardPaymentFee) AS MONEY), 0) SumaFee
     ,COUNT(*) NumberTransactions
    FROM CountryTaxes C
    INNER JOIN Agencies a
      ON C.AgencyId = a.AgencyId
    INNER JOIN Users u
      ON C.CreatedBy = u.UserId
    WHERE C.AgencyId = @AgencyId
    AND (CAST(C.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
    OR @CreationDate IS NULL)
    AND (C.CreatedBy = @UserId
    OR @UserId IS NULL)
    AND CardPayment = 1
    UNION ALL
    SELECT
      ISNULL(CAST(SUM(ISNULL(C.USD, 0) + ISNULL(C.Fee1, 0) + ISNULL(C.Fee2, 0)) AS MONEY), 0) Suma
     ,ISNULL(CAST(SUM(C.CardPaymentFee) AS MONEY), 0) SumaFee
     ,COUNT(*) NumberTransactions
    FROM ParkingTicketsCards C
    INNER JOIN Agencies a
      ON C.AgencyId = a.AgencyId
    INNER JOIN Users u
      ON C.CreatedBy = u.UserId
    WHERE C.AgencyId = @AgencyId
    AND (CAST(C.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
    OR @CreationDate IS NULL)
    AND (C.CreatedBy = @UserId
    OR @UserId IS NULL)
    AND CardPayment = 1
    UNION ALL
    SELECT
      ISNULL(CAST(SUM(C.USD) AS MONEY), 0) Suma
     ,ISNULL(CAST(SUM(C.CardPaymentFee) AS MONEY), 0) SumaFee
     ,COUNT(*) NumberTransactions
    FROM ReturnPayments C
    INNER JOIN Agencies a
      ON C.AgencyId = a.AgencyId
    INNER JOIN Users u
      ON C.CreatedBy = u.UserId
    WHERE C.AgencyId = @AgencyId
    AND (CAST(C.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
    OR @CreationDate IS NULL)
    AND (C.CreatedBy = @UserId
    OR @UserId IS NULL)
    AND CardPayment = 1
    UNION ALL
    SELECT
      ISNULL(CAST(SUM(C.Usd) AS MONEY), 0) Suma
     ,ISNULL(CAST(SUM(C.CardPaymentFee) AS MONEY), 0) SumaFee
     ,COUNT(*) NumberTransactions
    FROM Payments C
    INNER JOIN Financing F
      ON F.FinancingId = C.FinancingId
    INNER JOIN Agencies a
      ON F.AgencyId = a.AgencyId
    INNER JOIN Users u
      ON C.CreatedBy = u.UserId
    WHERE F.AgencyId = @AgencyId
    AND (CAST(C.CreatedOn AS DATE) = CAST(@CreationDate AS DATE)
    OR @CreationDate IS NULL)
    AND (C.CreatedBy = @UserId
    OR @UserId IS NULL)
    AND C.CardPayment = 1
    UNION ALL
    SELECT
      ISNULL(CAST(SUM(P.SellingValue) AS MONEY), 0) + (ISNULL(CAST(SUM(ISNULL(P.SellingValue, 0)) AS MONEY) / COUNT(ISNULL(P.PhoneSalesId, 0)), 0) * ISNULL(CAST(SUM(P.Tax) AS MONEY), 0) / 100) Suma
     ,ISNULL(CAST(SUM(P.CardPaymentFee) AS MONEY), 0) SumaFee
     ,COUNT(*) NumberTransactions
    FROM PhoneSales P
    INNER JOIN InventoryByAgency I
      ON I.InventoryByAgencyId = P.InventoryByAgencyId
    INNER JOIN Agencies a
      ON I.AgencyId = a.AgencyId
    INNER JOIN Users u
      ON P.CreatedBy = u.UserId
    WHERE I.AgencyId = @AgencyId
    AND (CAST(P.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
    OR @CreationDate IS NULL)
    AND (P.CreatedBy = @UserId
    OR @UserId IS NULL)
    AND P.CardPayment = 1
    UNION ALL
    SELECT
      ISNULL(CAST(SUM(C.USD) AS MONEY), 0) Suma
     ,ISNULL(CAST(SUM(C.CardPaymentFee) AS MONEY), 0) SumaFee
     ,COUNT(*) NumberTransactions
    FROM OtherPayments C
    INNER JOIN Agencies a
      ON C.AgencyId = a.AgencyId
    INNER JOIN Users u
      ON C.CreatedBy = u.UserId
    WHERE C.AgencyId = @AgencyId
    AND (CAST(C.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
    OR @CreationDate IS NULL)
    AND (C.CreatedBy = @UserId
    OR @UserId IS NULL)
    AND CardPayment = 1
    UNION ALL
    SELECT
      ISNULL(CAST(SUM(C.Usd) AS MONEY), 0) Suma
     ,ISNULL(CAST(SUM(C.CardPaymentFee) AS MONEY), 0) SumaFee
     ,COUNT(*) NumberTransactions
    FROM RentPayments C
    INNER JOIN Agencies a
      ON C.AgencyId = a.AgencyId
    INNER JOIN Users u
      ON C.CreatedBy = u.UserId
    WHERE C.AgencyId = @AgencyId
    AND (CAST(C.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
    OR @CreationDate IS NULL)
    AND (C.CreatedBy = @UserId
    OR @UserId IS NULL)
    AND CardPayment = 1
    UNION ALL
    SELECT
      ISNULL(CAST(SUM(C.Usd) AS MONEY), 0) Suma
     ,ISNULL(CAST(SUM(C.CardPaymentFee) AS MONEY), 0) SumaFee
     ,COUNT(*) NumberTransactions
    FROM DepositFinancingPayments C
    INNER JOIN Agencies a
      ON C.AgencyId = a.AgencyId
    INNER JOIN Users u
      ON C.CreatedBy = u.UserId
    WHERE C.AgencyId = @AgencyId
    AND (CAST(C.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
    OR @CreationDate IS NULL)
    AND (C.CreatedBy = @UserId
    OR @UserId IS NULL)
    AND CardPayment = 1
    UNION ALL
    SELECT
      ISNULL(CAST(SUM(C.Usd) AS MONEY), 0) Suma
     ,ISNULL(CAST(SUM(C.CardPaymentFee) AS MONEY), 0) SumaFee
     ,COUNT(*) NumberTransactions
    FROM TicketFeeServices C
    WHERE (CAST(CreationDate AS DATE) = CAST(@CreationDate AS DATE)
    OR @CreationDate IS NULL)
    AND AgencyId = @AgencyId
    AND (CreatedBy = @UserId
    OR @UserId IS NULL)
    AND UsedCard = 1
    UNION ALL
    SELECT
      (ISNULL(CAST(SUM(C.HeadphonesUsd) AS MONEY), 0) + ISNULL(CAST(SUM(C.ChargersUsd) AS MONEY), 0)) Suma
     ,ISNULL(CAST(SUM(C.CardPaymentFee) AS MONEY), 0) SumaFee
     ,(ISNULL(SUM(C.HeadphonesQuantity), 0) + ISNULL(SUM(C.ChargersQuantity), 0)) NumberTransactions
    FROM HeadphonesAndChargers C
    WHERE (CAST(CreationDate AS DATE) = CAST(@CreationDate AS DATE)
    OR @CreationDate IS NULL)
    AND AgencyId = @AgencyId
    AND (CreatedBy = @UserId
    OR @UserId IS NULL)
    AND CardPayment = 1
    UNION ALL
    SELECT
      ISNULL(CAST(SUM(C.Usd) AS MONEY), 0) Suma
     ,ISNULL(CAST(SUM(C.CardPaymentFee) AS MONEY), 0) SumaFee
     ,COUNT(*) NumberTransactions
    FROM OthersDetails C
    INNER JOIN Agencies a
      ON C.AgencyId = a.AgencyId
    INNER JOIN Users u
      ON C.CreatedBy = u.UserId
    WHERE C.AgencyId = @AgencyId
    AND (CAST(C.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
    OR @CreationDate IS NULL)
    AND (C.CreatedBy = @UserId
    OR @UserId IS NULL)
    AND CardPayment = 1
    UNION ALL

    --SELECT * FROM Tickets t WHERE t.TicketNumber in ('1476','1476')
    SELECT
      ISNULL(CAST(SUM(ISNULL(C.Usd, 0)) + SUM(ISNULL(C.Fee1, 0)) + SUM(ISNULL(C.Fee2, 0)) AS MONEY), 0) Suma
     ,ISNULL(CAST(MAX(C.CardPaymentFee) AS MONEY), 0) SumaFee
     ,1 NumberTransactions
    FROM Tickets C
    INNER JOIN Agencies a
      ON C.AgencyId = a.AgencyId
    INNER JOIN Users u
      ON C.CreatedBy = u.UserId
    WHERE C.AgencyId = @AgencyId
    AND (CAST(C.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
    OR @CreationDate IS NULL)
    AND (C.CreatedBy = @UserId
    OR @UserId IS NULL)
    AND CardPayment = 1
    GROUP BY C.CreatedBy
            ,C.AgencyId
            ,C.[TransactionGuid ]
    UNION ALL
    SELECT
      ISNULL(CAST(SUM(ISNULL(C.Total, 0) + ISNULL(C.OtherFees, 0)) AS MONEY), 0) Suma
     ,ISNULL(CAST(SUM(C.CardPaymentFee) AS MONEY), 0) SumaFee
     ,COUNT(*) NumberTransactions
    FROM ProvisionalReceipts C
    INNER JOIN Agencies a
      ON C.AgencyId = a.AgencyId
    INNER JOIN Cashiers ccre
      ON C.CreatedBy = ccre.CashierId
    INNER JOIN Users us
      ON ccre.UserId = us.UserId
    WHERE C.AgencyId = @AgencyId
    AND (CAST(C.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
    OR @CreationDate IS NULL)
    AND (C.CreatedBy = @CashierId
    OR @CashierId IS NULL)
    AND CardPayment = 1
    UNION ALL
    SELECT
      ISNULL(CAST(SUM(s.Total - s.CardPaymentFee) AS MONEY), 0) Suma
     ,ISNULL(CAST(SUM(s.CardPaymentFee) AS MONEY), 0) SumaFee
     ,COUNT(*) NumberTransactions
    FROM SystemToolsBill s
    INNER JOIN Agencies a
      ON s.AgencyId = a.AgencyId
    INNER JOIN Users u
      ON s.CreatedBy = u.UserId
    WHERE s.AgencyId = @AgencyId
    AND (CAST(s.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
    OR @CreationDate IS NULL)
    AND (s.CreatedBy = @UserId
    OR @UserId IS NULL)
    AND s.CardPayment = 1
    UNION ALL -- 6016
    SELECT
      ISNULL(i.[CardPayment], 0) Suma
     ,ISNULL(i.[CardFee], 0) SumaFee
     ,ISNULL([Transactions], 0) NumberTransactions
    FROM dbo.FN_GetInsuranceDailyCardPayments(@AgencyId, @UserId, @CreationDate) i) AS q;
END;







GO