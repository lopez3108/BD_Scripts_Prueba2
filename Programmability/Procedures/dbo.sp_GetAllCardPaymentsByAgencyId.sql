SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:19-09-2023
--CAMBIOS EN 5364, error en consulta de system tools.
-- 2024-06-26 DJ/5923: Dont sum City stickers card payments made with parent title
--Updated by JT/20-10-2024 TASK ADD NEW MOVEMENTS InsuranceMonthlyPayment InsuranceRegistration
-- 2025-01-28 JF/6315: REPORTES (CARD PAYMENTS Y BANKS) - TYPE & DESCRIPTION no muestra tipo de servicio correcto
-- 20204-02-20 JT/5939: Para los insurance se agrupa la información por el Nuevo campo TransactionGuid

--date 2025-06-06 JF task 6574 Error en list card payments con discounts

CREATE PROCEDURE [dbo].[sp_GetAllCardPaymentsByAgencyId] @AgencyId INT,
@CreationDate DATE = NULL,
@UserId INT = NULL
AS
  SET NOCOUNT ON;
  BEGIN
    DECLARE @CashierId INT = NULL;
    SET @CashierId = (SELECT
        CashierId
      FROM Cashiers
      WHERE UserId = @UserId)
    SELECT

      *
     ,ISNULL((Queryp.Usd + Queryp.Fee), 0) AS Total
     ,ISNULL((Queryp.FeeUsd + Queryp.TotalPay), 0) AS TotalBatch
    FROM (SELECT
        cp.CardPaymentId
       ,ISNULL(cp.Usd, 0) Usd
       ,'' DescriptionParentCitySticker
       ,ISNULL(cp.Fee, 0) Fee
       ,ISNULL(cp.FeeUsd, 0) FeeUsd
       ,ISNULL(cp.TotalPay, 0) TotalPay
       ,cp.NumberPayments
       ,CAST(cp.Batch AS BIT) Batch
       ,cp.CreatedBy
       ,cp.CreationDate
       ,cp.AgencyId
       ,cp.LastUpdatedBy
       ,cp.LastUpdatedOn
       ,us.Name AS LastUpdatedByName
       ,'C00' Type
       ,'card_payments' AS Description
      FROM CardPayments cp
      INNER JOIN Agencies a
        ON cp.AgencyId = a.AgencyId
      INNER JOIN Users u
        ON cp.CreatedBy = u.UserId
      INNER JOIN Users us
        ON cp.LastUpdatedBy = us.UserId
  
      WHERE cp.AgencyId = @AgencyId
      AND (CAST(cp.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
      OR @CreationDate IS NULL)
      AND (cp.CreatedBy = @UserId
      OR @UserId IS NULL)
      UNION ALL


      SELECT
        0 CardPaymentId
       ,(ISNULL(ISNULL(t.Usd, 0) - ISNULL(pc.Usd, 0) + ISNULL(t.Fee1, 0), 0)
        + ISNULL((SELECT
            ISNULL(ISNULL(cs.Usd, 0) + ISNULL(cs.Fee1, 0), 0)
          FROM CityStickers cs
          WHERE cs.TitleParentId = t.TitleId)
        , 0)
        ) Usd
       ,CASE
          WHEN EXISTS (SELECT
                *
              FROM CityStickers cs
              WHERE cs.TitleParentId = t.TitleId) THEN (SELECT TOP 1
                pe.Name
              FROM ProvidersEls pe
              WHERE pe.Code = 'C03')
          ELSE NULL
        END

        DescriptionParentCitySticker
       ,ISNULL(t.CardPaymentFee, 0) Fee

       ,0 FeeUsd
       ,0 TotalPay
       ,COUNT(*) NumberPayments
       ,CAST(0 AS BIT) Batch
       ,t.CreatedBy
       ,t.CreationDate
       ,t.AgencyId
       ,t.UpdatedBy AS LastUpdatedBy
       ,t.UpdatedOn AS LastUpdatedOn
       ,us.Name AS LastUpdatedByName
       ,'C01' Type
       ,'titles_and_plates' AS Description
      FROM Titles t
      INNER JOIN Users us
        ON UpdatedBy = us.UserId
      LEFT JOIN PromotionalCodesStatus Pt ON t.TitleId = Pt.TitleId
      LEFT JOIN PromotionalCodes pc ON Pt.PromotionalCodeId = pc.PromotionalCodeId
      WHERE (CAST(t.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
      OR @CreationDate IS NULL)
      AND t.AgencyId = @AgencyId
      AND (t.CreatedBy = @UserId
      OR @UserId IS NULL)
      AND t.CardPayment = 1
      GROUP BY t.Usd
              ,t.Fee1
              ,t.CardPaymentFee
              ,t.CreatedBy
              ,t.CreationDate
              ,t.AgencyId
              ,t.UpdatedBy
              ,t.UpdatedOn
              ,us.Name
              ,t.TitleId
              ,pc.Usd

      UNION ALL



      SELECT
        0 CardPaymentId
       ,ISNULL(trp.Usd, 0) + ISNULL(trp.LaminationFee, 0) Usd
       ,'' DescriptionParentCitySticker
       ,ISNULL(trp.CardPaymentFee, 0) Fee
       ,0 FeeUsd
       ,0 TotalPay
       ,COUNT(*) NumberPayments
       ,CAST(0 AS BIT) Batch
       ,trp.CreatedBy
       ,trp.CreatedOn CreationDate
       ,trp.AgencyId
       ,trp.UpdatedBy AS LastUpdatedBy
       ,trp.UpdatedOn AS LastUpdatedOn
       ,us.Name AS LastUpdatedByName
       ,'C02' Type
       ,(SELECT TOP 1
            pe.Name
          FROM ProvidersEls pe
          WHERE pe.Code = 'C02')
        AS Description
      FROM TRP trp
      INNER JOIN Users us
        ON trp.UpdatedBy = us.UserId
      WHERE CAST(trp.CreatedOn AS DATE) = CAST(@CreationDate AS DATE)
      AND trp.AgencyId = @AgencyId
      AND (trp.CreatedBy = @UserId
      OR @UserId IS NULL)
      AND trp.CardPayment = 1
      GROUP BY trp.Usd
              ,trp.Fee1
              ,trp.CardPaymentFee
              ,trp.CreatedBy
              ,trp.CreatedOn
              ,trp.AgencyId
              ,trp.UpdatedBy
              ,trp.UpdatedOn
              ,us.Name
              ,trp.LaminationFee
      UNION ALL




      SELECT
        0 CardPaymentId
       ,ISNULL(c.Usd - ISNULL(pc.Usd, 0) + c.Fee1, 0) Usd
       ,'' DescriptionParentCitySticker
       ,ISNULL(c.CardPaymentFee, 0) Fee
       ,0 FeeUsd
       ,0 TotalPay
       ,COUNT(*) NumberPayments
       ,CAST(0 AS BIT) Batch
       ,c.CreatedBy
       ,c.CreationDate
       ,c.AgencyId
       ,c.UpdatedBy AS LastUpdatedBy
       ,c.UpdatedOn AS LastUpdatedOn
       ,us.Name AS LastUpdatedByName
       ,'C03' Type
       ,(SELECT TOP 1
            pe.Name
          FROM ProvidersEls pe
          WHERE pe.Code = 'C03')
        AS Description
      FROM CityStickers c
      INNER JOIN Users us
        ON c.UpdatedBy = us.UserId
         LEFT JOIN PromotionalCodesStatus Pt ON  c.CityStickerId = Pt.CityStickerId
      LEFT JOIN PromotionalCodes pc ON Pt.PromotionalCodeId = pc.PromotionalCodeId
      WHERE (CAST(c.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
      OR @CreationDate IS NULL)
      AND c.AgencyId = @AgencyId
      AND (c.CreatedBy = @UserId
      OR @UserId IS NULL)
      AND c.TitleParentId IS NULL --Only city stickers no child of titles
      AND c.CardPayment = 1
      GROUP BY c.Usd
              ,c.Fee1
              ,c.CardPaymentFee
              ,c.CreatedBy
              ,c.CreationDate
              ,c.AgencyId
              ,c.UpdatedBy
              ,c.UpdatedOn
              ,us.Name
              ,pc.Usd

      UNION ALL



      SELECT
        0 CardPaymentId
       ,ISNULL(ISNULL(p.Usd, 0) - ISNULL(pc.Usd, 0) + ISNULL(p.Fee1, 0), 0) Usd
       ,'' DescriptionParentCitySticker
       ,ISNULL(p.CardPaymentFee, 0) Fee
       ,0 FeeUsd
       ,0 TotalPay
       ,COUNT(*) NumberPayments
       ,CAST(0 AS BIT) Batch
       ,p.CreatedBy
       ,p.CreationDate
       ,p.AgencyId
       ,p.UpdatedBy AS LastUpdatedBy
       ,p.UpdatedOn AS LastUpdatedOn
       ,us.Name AS LastUpdatedByName
       ,'C04' Type
       ,(SELECT TOP 1
            pe.Name
          FROM ProvidersEls pe
          WHERE pe.Code = 'C04')
        AS Description
      FROM PlateStickers p  --  esa tabla  en la lógica de  negocio se llama  REGISTRATION RENEWALS
      INNER JOIN Users us
        ON p.UpdatedBy = us.UserId
            LEFT JOIN PromotionalCodesStatus Pt ON  p.PlateStickerId = Pt.PlateStickerId
      LEFT JOIN PromotionalCodes pc ON Pt.PromotionalCodeId = pc.PromotionalCodeId
      WHERE (CAST(p.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
      OR @CreationDate IS NULL)
      AND p.AgencyId = @AgencyId
      AND (p.CreatedBy = @UserId
      OR @UserId IS NULL)
      AND p.CardPayment = 1
      GROUP BY p.Usd
              ,p.Fee1
              ,p.CardPaymentFee
              ,p.CreatedBy
              ,p.CreationDate
              ,p.AgencyId
              ,p.UpdatedBy
              ,p.UpdatedOn
              ,us.Name
              ,pc.Usd
      UNION ALL



      SELECT
        0 CardPaymentId
       ,ISNULL(ISNULL(t.Usd, 0) + ISNULL(t.Fee1, 0), 0) Usd
       ,'' DescriptionParentCitySticker
       ,ISNULL(t.CardPaymentFee, 0) Fee
       ,0 FeeUsd
       ,0 TotalPay
       ,COUNT(*) NumberPayments
       ,CAST(0 AS BIT) Batch
       ,t.CreatedBy
       ,t.CreationDate
       ,t.AgencyId
       ,t.UpdatedBy AS LastUpdatedBy
       ,t.UpdatedOn AS LastUpdatedOn
       ,us.Name AS LastUpdatedByName
       ,'C05' Type
       ,(SELECT TOP 1
            pe.Name
          FROM ProvidersEls pe
          WHERE pe.Code = 'C05')
        AS Description
      FROM TitleInquiry t
      INNER JOIN Users us
        ON t.UpdatedBy = us.UserId
      WHERE (CAST(t.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
      OR @CreationDate IS NULL)
      AND t.AgencyId = @AgencyId
      AND (t.CreatedBy = @UserId
      OR @UserId IS NULL)
      AND t.CardPayment = 1
      GROUP BY t.Usd
              ,t.Fee1
              ,t.CardPaymentFee
              ,t.CreatedBy
              ,t.CreationDate
              ,t.AgencyId
              ,t.UpdatedBy
              ,t.UpdatedOn
              ,us.Name
      UNION ALL



      SELECT
        0 CardPaymentId
       ,ISNULL(ISNULL(pk.Usd, 0) + ISNULL(pk.Fee1, 0) + ISNULL(pk.Fee2, 0), 0) Usd
       ,'' DescriptionParentCitySticker
       ,ISNULL(pk.CardPaymentFee, 0) Fee
       ,0 FeeUsd
       ,0 TotalPay
       ,COUNT(*) NumberPayments
       ,CAST(0 AS BIT) Batch
       ,pk.CreatedBy
       ,pk.CreationDate
       ,pk.AgencyId
       ,pk.UpdatedBy AS LastUpdatedBy
       ,pk.UpdatedOn AS LastUpdatedOn
       ,us.Name AS LastUpdatedByName
       ,'C06' Type
       ,(SELECT TOP 1
            pe.Name
          FROM ProvidersEls pe
          WHERE pe.Code = 'C06')
        AS Description
      FROM ParkingTickets pk
      INNER JOIN Users us
        ON pk.UpdatedBy = us.UserId
      WHERE (CAST(pk.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
      OR @CreationDate IS NULL)
      AND pk.AgencyId = @AgencyId
      AND (pk.CreatedBy = @UserId
      OR @UserId IS NULL)
      AND pk.CardPayment = 1
      GROUP BY pk.Usd
              ,pk.Fee1
              ,pk.Fee2
              ,pk.CardPaymentFee
              ,pk.CreatedBy
              ,pk.CreationDate
              ,pk.AgencyId
              ,pk.UpdatedBy
              ,pk.UpdatedOn
              ,us.Name
      UNION ALL



      SELECT
        0 CardPaymentId
       ,ISNULL(o.Usd, 0) Usd
       ,'' DescriptionParentCitySticker
       ,ISNULL(o.CardPaymentFee, 0) Fee
       ,0 FeeUsd
       ,0 TotalPay
       ,COUNT(*) NumberPayments
       ,CAST(0 AS BIT) Batch
       ,o.CreatedBy
       ,o.CreationDate
       ,o.AgencyId
       ,o.UpdatedBy AS LastUpdatedBy
       ,o.UpdatedOn AS LastUpdatedOn
       ,us.Name AS LastUpdatedByName
       ,'C07' Type
       ,'other_details_detail' AS Description
      FROM OthersDetails o
      INNER JOIN Users us
        ON o.UpdatedBy = us.UserId
      WHERE (CAST(o.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
      OR @CreationDate IS NULL)
      AND o.AgencyId = @AgencyId
      AND (o.CreatedBy = @UserId
      OR @UserId IS NULL)
      AND o.CardPayment = 1
      GROUP BY o.Usd
              ,o.CardPaymentFee
              ,o.CreatedBy
              ,o.CreationDate
              ,o.AgencyId
              ,o.UpdatedBy
              ,o.UpdatedOn
              ,us.Name
      UNION ALL


      SELECT
        0 CardPaymentId
       ,ISNULL(ISNULL(ct.Usd, 0) + ISNULL(ct.Fee1, 0), 0) Usd
       ,'' DescriptionParentCitySticker
       ,ISNULL(ct.CardPaymentFee, 0) Fee
       ,0 FeeUsd
       ,0 TotalPay
       ,COUNT(*) NumberPayments
       ,CAST(0 AS BIT) Batch
       ,ct.CreatedBy
       ,ct.CreationDate
       ,ct.AgencyId
       ,ct.UpdatedBy AS LastUpdatedBy
       ,ct.UpdatedOn AS LastUpdatedOn
       ,us.Name AS LastUpdatedByName
       ,'C08' Type
       ,(SELECT TOP 1
            pe.Name
          FROM ProvidersEls pe
          WHERE pe.Code = 'C08')
        AS Description
      FROM CountryTaxes ct
      INNER JOIN Users us
        ON ct.UpdatedBy = us.UserId
      WHERE (CAST(ct.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
      OR @CreationDate IS NULL)
      AND ct.AgencyId = @AgencyId
      AND (ct.CreatedBy = @UserId
      OR @UserId IS NULL)
      AND ct.CardPayment = 1
      GROUP BY ct.Usd
              ,ct.Fee1
              ,ct.CardPaymentFee
              ,ct.CreatedBy
              ,ct.CreationDate
              ,ct.AgencyId
              ,ct.UpdatedBy
              ,ct.UpdatedOn
              ,us.Name

      UNION ALL
      SELECT
        0 CardPaymentId
       ,ISNULL(ISNULL(pc.Usd, 0) + ISNULL(pc.Fee1, 0) + ISNULL(pc.Fee2, 0), 0) Usd
       ,'' DescriptionParentCitySticker
       ,ISNULL(pc.CardPaymentFee, 0) Fee
       ,0 FeeUsd
       ,0 TotalPay
       ,COUNT(*) NumberPayments
       ,CAST(0 AS BIT) Batch
       ,pc.CreatedBy
       ,pc.CreationDate
       ,pc.AgencyId
       ,pc.UpdatedBy AS LastUpdatedBy
       ,pc.UpdatedOn AS LastUpdatedOn
       ,us.Name AS LastUpdatedByName
       ,'C09' Type
       ,NULL AS Description -- Ya no se  utiliza en el daily ( fue eliminado del sistema )
      FROM ParkingTicketsCards pc
      INNER JOIN Users us
        ON pc.UpdatedBy = us.UserId
      WHERE (CAST(pc.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
      OR @CreationDate IS NULL)
      AND pc.AgencyId = @AgencyId
      AND (pc.CreatedBy = @UserId
      OR @UserId IS NULL)
      AND pc.CardPayment = 1
      GROUP BY pc.Usd
              ,pc.Fee1
              ,pc.Fee2
              ,pc.CardPaymentFee
              ,pc.CreatedBy
              ,pc.CreationDate
              ,pc.AgencyId
              ,pc.UpdatedBy
              ,pc.UpdatedOn
              ,us.Name
      UNION ALL
      SELECT
        0 CardPaymentId
       ,ISNULL(r.Usd, 0) Usd
       ,'' DescriptionParentCitySticker
       ,ISNULL(r.CardPaymentFee, 0) Fee
       ,0 FeeUsd
       ,0 TotalPay
       ,COUNT(*) NumberPayments
       ,CAST(0 AS BIT) Batch
       ,r.CreatedBy
       ,r.CreationDate
       ,r.AgencyId
       ,r.CreatedBy AS LastUpdatedBy
       ,r.CreationDate AS LastUpdatedOn
       ,us.Name AS LastUpdatedByName
       ,'C10' Type
       ,'returned_checks' AS Description -- no se está utlizando
      FROM ReturnPayments r
      INNER JOIN Users us
        ON r.CreatedBy = us.UserId
      WHERE (CAST(r.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
      OR @CreationDate IS NULL)
      AND r.AgencyId = @AgencyId
      AND (r.CreatedBy = @UserId
      OR @UserId IS NULL)
      AND r.CardPayment = 1
      GROUP BY r.Usd
              ,r.CardPaymentFee
              ,r.CreatedBy
              ,r.CreationDate
              ,r.AgencyId
              ,us.Name
      UNION ALL
      SELECT
        0 CardPaymentId
       ,ISNULL(C.Usd, 0) Usd
       ,'' DescriptionParentCitySticker
       ,ISNULL(C.CardPaymentFee, 0) Fee
       ,0 FeeUsd
       ,0 TotalPay
       ,COUNT(*) NumberPayments
       ,CAST(0 AS BIT) Batch
       ,C.CreatedBy
       ,C.CreatedOn
       ,F.AgencyId
       ,C.CreatedBy AS LastUpdatedBy
       ,C.CreatedOn AS LastUpdatedOn
       ,us.Name AS LastUpdatedByName
       ,'C11' Type
       ,NULL AS Description --  NO SE ENCONTRÓ EN ELDAILY
      FROM Payments C
      INNER JOIN Financing F
        ON F.FinancingId = C.FinancingId
      INNER JOIN Agencies a
        ON F.AgencyId = a.AgencyId
      INNER JOIN Users us
        ON C.CreatedBy = us.UserId
      WHERE (CAST(C.CreatedOn AS DATE) = CAST(@CreationDate AS DATE)
      OR @CreationDate IS NULL)
      AND F.AgencyId = @AgencyId
      AND (C.CreatedBy = @UserId
      OR @UserId IS NULL)
      AND C.CardPayment = 1
      GROUP BY C.Usd
              ,C.CardPaymentFee
              ,C.CreatedBy
              ,C.CreatedOn
              ,F.AgencyId
              ,us.Name
      UNION ALL
      SELECT
        0 CardPaymentId
       ,ISNULL(P.SellingValue, 0) + (ISNULL(P.SellingValue, 0) * (ISNULL(P.Tax, 0)) / 100) Usd
       ,'' DescriptionParentCitySticker
       ,ISNULL(P.CardPaymentFee, 0) Fee
       ,0 FeeUsd
       ,0 TotalPay
       ,COUNT(*) NumberPayments
       ,CAST(0 AS BIT) Batch
       ,P.CreatedBy
       ,P.CreationDate
       ,I.AgencyId
       ,P.LastUpdatedBy
       ,P.LastUpdatedOn
       ,us.Name AS LastUpdatedByName
       ,'C12' Type
       ,(SELECT TOP 1
            p1.Name
          FROM Providers p1
          JOIN ProviderTypes pt
            ON p1.ProviderTypeId = pt.ProviderTypeId
          WHERE pt.Code = 'C12'
          AND p1.Active = 1)
        AS Description
      FROM PhoneSales P
      INNER JOIN InventoryByAgency I
        ON I.InventoryByAgencyId = P.InventoryByAgencyId
      INNER JOIN Users us
        ON LastUpdatedBy = us.UserId
      WHERE (CAST(P.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
      OR @CreationDate IS NULL)
      AND I.AgencyId = @AgencyId
      AND (P.CreatedBy = @UserId
      OR @UserId IS NULL)
      AND P.CardPayment = 1
      GROUP BY P.SellingValue
              ,P.Tax
              ,P.CardPaymentFee
              ,P.CreatedBy
              ,P.CreationDate
              ,I.AgencyId
              ,P.LastUpdatedBy
              ,P.LastUpdatedOn
              ,us.Name
      UNION ALL
      SELECT
        0 CardPaymentId
       ,ISNULL(op.Usd, 0) Usd
       ,'' DescriptionParentCitySticker
       ,ISNULL(op.CardPaymentFee, 0) Fee
       ,0 FeeUsd
       ,0 TotalPay
       ,COUNT(*) NumberPayments
       ,CAST(0 AS BIT) Batch
       ,op.CreatedBy
       ,op.CreationDate
       ,op.AgencyId
       ,op.LastUpdatedBy
       ,op.LastUpdatedOn
       ,us.Name AS LastUpdatedByName
       ,'C13' Type
       ,'other_payments' AS Description
      FROM OtherPayments op
      INNER JOIN Users us
        ON op.LastUpdatedBy = us.UserId
      WHERE (CAST(op.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
      OR @CreationDate IS NULL)
      AND op.AgencyId = @AgencyId
      AND (op.CreatedBy = @UserId
      OR @UserId IS NULL)
      AND op.CardPayment = 1
      GROUP BY op.Usd
              ,op.CardPaymentFee
              ,op.CreatedBy
              ,op.CreationDate
              ,op.AgencyId
              ,op.LastUpdatedBy
              ,op.LastUpdatedOn
              ,us.Name
      UNION ALL
      SELECT
        0 CardPaymentId
       ,ISNULL(rp.Usd, 0) Usd
       ,'' DescriptionParentCitySticker
       ,ISNULL(rp.CardPaymentFee, 0) Fee
       ,0 FeeUsd
       ,0 TotalPay
       ,COUNT(*) NumberPayments
       ,CAST(0 AS BIT) Batch
       ,rp.CreatedBy
       ,rp.CreationDate
       ,rp.AgencyId
       ,rp.CreatedBy AS LastUpdatedBy
       ,rp.CreationDate AS LastUpdatedOn
       ,us.Name AS LastUpdatedByName
       ,'C14' Type
       ,'rent_payments' AS Description
      FROM RentPayments rp
      INNER JOIN Users us
        ON rp.CreatedBy = us.UserId
      WHERE (CAST(rp.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
      OR @CreationDate IS NULL)
      AND rp.AgencyId = @AgencyId
      AND (rp.CreatedBy = @UserId
      OR @UserId IS NULL)
      AND rp.CardPayment = 1
      GROUP BY rp.Usd
              ,rp.CardPaymentFee
              ,rp.CreatedBy
              ,rp.CreationDate
              ,rp.AgencyId
              ,us.Name

      UNION ALL
      SELECT
        0 CardPaymentId
       ,ISNULL(d.Usd, 0) Usd
       ,'' DescriptionParentCitySticker
       ,ISNULL(d.CardPaymentFee, 0) Fee
       ,0 FeeUsd
       ,0 TotalPay
       ,COUNT(*) NumberPayments
       ,CAST(0 AS BIT) Batch
       ,d.CreatedBy
       ,d.CreationDate
       ,d.AgencyId
       ,d.CreatedBy AS LastUpdatedBy
       ,d.CreationDate AS LastUpdatedOn
       ,us.Name AS LastUpdatedByName
       ,'C15' Type
       ,'deposit_payments' AS Description
      FROM DepositFinancingPayments d
      INNER JOIN Users us
        ON d.CreatedBy = us.UserId
      WHERE (CAST(d.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
      OR @CreationDate IS NULL)
      AND d.AgencyId = @AgencyId
      AND (d.CreatedBy = @UserId
      OR @UserId IS NULL)
      AND d.CardPayment = 1
      GROUP BY d.Usd
              ,d.CardPaymentFee
              ,d.CreatedBy
              ,d.CreationDate
              ,d.AgencyId
              ,us.Name

      UNION ALL
      SELECT
        0 CardPaymentId
       ,ISNULL(tf.Usd, 0) Usd
       ,'' DescriptionParentCitySticker
       ,ISNULL(tf.CardPaymentFee, 0) Fee
       ,0 FeeUsd
       ,0 TotalPay
       ,COUNT(*) NumberPayments
       ,CAST(0 AS BIT) Batch
       ,tf.CreatedBy
       ,tf.CreationDate
       ,tf.AgencyId
       ,tf.UpdatedBy AS LastUpdatedBy
       ,tf.UpdatedOn AS LastUpdatedOn
       ,us.Name AS LastUpdatedByName
       ,'C16' Type
       ,'fee_services_detail' AS Description
      FROM TicketFeeServices tf
      INNER JOIN Users us
        ON tf.UpdatedBy = us.UserId
      WHERE (CAST(tf.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
      OR @CreationDate IS NULL)
      AND tf.AgencyId = @AgencyId
      AND (tf.CreatedBy = @UserId
      OR @UserId IS NULL)
      AND tf.UsedCard = 1
      GROUP BY tf.Usd
              ,tf.CardPaymentFee
              ,tf.CreatedBy
              ,tf.CreationDate
              ,tf.UpdatedBy
              ,tf.UpdatedOn
              ,tf.AgencyId
              ,us.Name
      UNION ALL
      SELECT
        0 CardPaymentId
       ,ISNULL(SUM(ISNULL(t.Usd, 0)) + SUM(ISNULL(t.Fee1, 0)) + SUM(ISNULL(t.Fee2, 0)), 0) Usd
       ,'' DescriptionParentCitySticker
       ,MAX(ISNULL(t.CardPaymentFee, 0)) Fee
       ,0 FeeUsd
       ,0 TotalPay
       ,1 NumberPayments
       ,CAST(0 AS BIT) Batch
       ,t.CreatedBy
       ,t.CreationDate
       ,t.AgencyId
       ,(SELECT TOP 1
            LastUpdatedBy
          FROM Tickets t1
          WHERE t1.[TransactionGuid ] = t.[TransactionGuid ]
          ORDER BY t1.LastUpdatedOn DESC)
        AS LastUpdatedBy
       ,MAX(t.LastUpdatedOn) AS LastUpdatedOn
       ,(SELECT TOP 1
            us1.Name
          FROM Users us1
          INNER JOIN Tickets t1
            ON t1.LastUpdatedBy = us1.UserId
          WHERE t1.[TransactionGuid ] = t.[TransactionGuid ]
          ORDER BY t1.LastUpdatedOn DESC)
        AS LastUpdatedByName

        --       ,us.Name AS LastUpdatedByName
       ,'C17' Type
       ,'tickets' AS Description
      FROM Tickets t
      INNER JOIN Users us
        ON t.LastUpdatedBy = us.UserId
      WHERE (CAST(t.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
      OR @CreationDate IS NULL)
      AND t.AgencyId = @AgencyId
      AND (t.CreatedBy = @UserId
      OR @UserId IS NULL)
      AND t.CardPayment = 1
      GROUP BY t.CreatedBy
              ,t.CreationDate
              ,t.AgencyId
              ,us.Name
              ,t.[TransactionGuid ]
      UNION ALL
      SELECT
        0 CardPaymentId
       ,ISNULL(h.HeadphonesUsd, 0) + ISNULL(h.ChargersUsd, 0) Usd
       ,'' DescriptionParentCitySticker
       ,ISNULL(h.CardPaymentFee, 0) Fee
       ,0 FeeUsd
       ,0 TotalPay
       ,COUNT(*) NumberPayments
       ,CAST(0 AS BIT) Batch
       ,h.CreatedBy
       ,h.CreationDate
       ,h.AgencyId
       ,h.UpdatedBy AS LastUpdatedBy
       ,h.UpdatedOn AS LastUpdatedOn
       ,us.Name AS LastUpdatedByName
       ,'C22' Type
       ,(SELECT TOP 1
            p.Name
          FROM ProviderTypes pt
          JOIN Providers p
            ON pt.ProviderTypeId = p.ProviderTypeId
          WHERE pt.Code = 'C22'
          AND p.Active = 1)
        AS Description
      FROM HeadphonesAndChargers h
      INNER JOIN Users us
        ON h.UpdatedBy = us.UserId
      WHERE (CAST(h.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
      OR @CreationDate IS NULL)
      AND h.AgencyId = @AgencyId
      AND (h.CreatedBy = @UserId
      OR @UserId IS NULL)
      AND h.CardPayment = 1
      GROUP BY h.HeadphonesUsd
              ,h.ChargersUsd
              ,h.CardPaymentFee
              ,h.CreatedBy
              ,h.CreationDate
              ,h.UpdatedBy
              ,h.UpdatedOn
              ,h.AgencyId
              ,us.Name
      UNION ALL
      SELECT
        0 CardPaymentId
       ,ISNULL(ISNULL(c.Total, 0) + ISNULL(c.OtherFees, 0), 0) Usd
       ,'' DescriptionParentCitySticker
       ,ISNULL(c.CardPaymentFee, 0) Fee
       ,0 FeeUsd
       ,0 TotalPay
       ,COUNT(*) NumberPayments
       ,CAST(0 AS BIT) Batch
       ,c.CreatedBy
       ,c.CreationDate
       ,c.AgencyId
       ,CASE
          WHEN c.CompletedBy IS NOT NULL THEN c.CompletedBy
          ELSE c.CreatedBy
        END AS LastUpdatedBy
       ,CASE
          WHEN c.CompletedOn IS NOT NULL THEN c.CompletedOn
          ELSE c.CreationDate
        END AS LastUpdatedOn
       ,CASE
          WHEN c.CompletedBy IS NOT NULL THEN usc.Name
          ELSE us.Name
        END AS LastUpdatedByName
       ,'C23' Type
       ,'provisional_receipts' AS Description
      FROM ProvisionalReceipts c
      INNER JOIN Cashiers ccre
        ON c.CreatedBy = ccre.CashierId
      INNER JOIN Users us
        ON ccre.UserId = us.UserId
      LEFT JOIN Cashiers cc
        ON c.CompletedBy = cc.CashierId
      LEFT JOIN Users usc
        ON cc.UserId = usc.UserId
      WHERE (CAST(c.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
      OR @CreationDate IS NULL)
      AND c.AgencyId = @AgencyId
      AND (c.CreatedBy = @CashierId
      OR @CashierId IS NULL)
      AND c.CardPayment = 1
      GROUP BY c.Total
              ,c.OtherFees
              ,c.CardPaymentFee
              ,c.CreatedBy
              ,c.CreationDate
              ,c.CompletedBy
              ,c.CompletedOn
              ,c.AgencyId
              ,usc.Name
              ,us.Name
      UNION ALL
      SELECT
        0 CardPaymentId
       ,ISNULL(s.Total, 0) - ISNULL(s.CardPaymentFee, 0) Usd
       ,'' DescriptionParentCitySticker
       ,ISNULL(s.CardPaymentFee, 0) Fee
       ,0 FeeUsd
       ,0 TotalPay
       ,COUNT(*) NumberPayments
       ,CAST(0 AS BIT) Batch
       ,s.CreatedBy
       ,s.CreationDate
       ,s.AgencyId
       ,s.CreatedBy AS LastUpdatedBy
       ,s.CreationDate AS LastUpdatedOn
       ,dbo.Users.Name AS LastUpdatedByName
       ,'C18' Type
       ,'system_tools' AS Description
      FROM SystemToolsBill s
      INNER JOIN dbo.Users
        ON dbo.Users.UserId = s.CreatedBy
      WHERE (CAST(s.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
      OR @CreationDate IS NULL)
      AND s.AgencyId = @AgencyId
      AND (s.CreatedBy = @UserId
      OR @UserId IS NULL)
      AND s.CardPayment = 1
      GROUP BY s.Total
              ,s.CardPaymentFee
              ,s.CreatedBy
              ,s.CreationDate
              ,s.AgencyId
              ,Users.Name

      UNION ALL
      SELECT
        0 CardPaymentId
        --       ,ISNULL(s.USD, 0) Usd
       ,ISNULL(s.Usd, 0) + ISNULL(s.FeeService, 0) Usd
       ,'' DescriptionParentCitySticker
       ,ISNULL(s.CardFee, 0) Fee
       ,0 FeeUsd
       ,0 TotalPay
       ,COUNT(*) NumberPayments
       ,CAST(0 AS BIT) Batch
       ,s.CreatedBy
       ,s.CreationDate
       ,s.CreatedInAgencyId
       ,s.CreatedBy AS LastUpdatedBy
       ,s.CreationDate AS LastUpdatedOn
       ,us.Name AS LastUpdatedByName
       ,'C24' Type
       ,'new_policy' AS Description
      FROM InsurancePolicy s
      INNER JOIN Users us
        ON s.LastUpdatedBy = us.UserId
      WHERE (CAST(s.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
      OR @CreationDate IS NULL)
      AND s.CreatedInAgencyId = @AgencyId
      AND (s.CreatedBy = @UserId
      OR @UserId IS NULL)
      AND s.CardFee IS NOT NULL
      AND s.CardFee > 0
      GROUP BY s.Usd
              ,s.CardFee
              ,s.FeeService
              ,s.CreatedBy
              ,s.CreationDate
              ,s.CreatedInAgencyId
              ,us.Name
      UNION ALL
      SELECT
        0 CardPaymentId
       ,ISNULL(s.Usd, 0) + ISNULL(s.MonthlyPaymentServiceFee, 0) Usd
       ,'' DescriptionParentCitySticker
       ,ISNULL(s.CardFee, 0) Fee
       ,0 FeeUsd
       ,0 TotalPay
       ,COUNT(*) NumberPayments
       ,CAST(0 AS BIT) Batch
       ,s.CreatedBy
       ,s.CreationDate
       ,s.CreatedInAgencyId
       ,s.CreatedBy AS LastUpdatedBy
       ,s.CreationDate AS LastUpdatedOn
       ,us.Name AS LastUpdatedByName
       ,'C24' Type
       ,ict.Description AS Description
      FROM InsuranceMonthlyPayment s
      INNER JOIN Users us
        ON s.LastUpdatedBy = us.UserId
      INNER JOIN InsuranceCommissionType ict
        ON s.InsuranceCommissionTypeId = ict.InsuranceCommissionTypeId
      WHERE (CAST(s.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
      OR @CreationDate IS NULL)
      AND s.CreatedInAgencyId = @AgencyId
      AND (s.CreatedBy = @UserId
      OR @UserId IS NULL)
      AND s.CardFee IS NOT NULL
      AND s.CardFee > 0
      AND ict.Code = 'C04'
      GROUP BY s.InsuranceMonthlyPaymentId
              ,s.MonthlyPaymentServiceFee
              ,s.Usd
              ,s.CardFee
              ,s.CreatedBy
              ,s.CreationDate
              ,s.CreatedInAgencyId
              ,us.Name
              ,ict.Description

      UNION ALL
      SELECT
        0 CardPaymentId
       ,ISNULL(s.Usd, 0) + ISNULL(s.MonthlyPaymentServiceFee, 0) Usd
       ,'' DescriptionParentCitySticker
       ,ISNULL(s.CardFee, 0) Fee
       ,0 FeeUsd
       ,0 TotalPay
       ,COUNT(*) NumberPayments
       ,CAST(0 AS BIT) Batch
       ,s.CreatedBy
       ,s.CreationDate
       ,s.CreatedInAgencyId
       ,s.CreatedBy AS LastUpdatedBy
       ,s.CreationDate AS LastUpdatedOn
       ,us.Name AS LastUpdatedByName
       ,'C24' Type
       ,ict.Description AS Description
      FROM InsuranceMonthlyPayment s
      INNER JOIN Users us
        ON s.LastUpdatedBy = us.UserId
      INNER JOIN InsuranceCommissionType ict
        ON s.InsuranceCommissionTypeId = ict.InsuranceCommissionTypeId
      WHERE (CAST(s.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
      OR @CreationDate IS NULL)
      AND s.CreatedInAgencyId = @AgencyId
      AND (s.CreatedBy = @UserId
      OR @UserId IS NULL)
      AND s.CardFee IS NOT NULL
      AND s.CardFee > 0
      AND ict.Code = 'C03'
      GROUP BY s.InsuranceMonthlyPaymentId
              ,s.MonthlyPaymentServiceFee
              ,s.Usd
              ,s.CardFee
              ,s.CreatedBy
              ,s.CreationDate
              ,s.CreatedInAgencyId
              ,us.Name
              ,ict.Description

      UNION ALL
      SELECT
        0 CardPaymentId
       ,ISNULL(s.Usd, 0) + ISNULL(s.MonthlyPaymentServiceFee, 0) Usd
       ,'' DescriptionParentCitySticker
       ,ISNULL(s.CardFee, 0) Fee
       ,0 FeeUsd
       ,0 TotalPay
       ,COUNT(*) NumberPayments
       ,CAST(0 AS BIT) Batch
       ,s.CreatedBy
       ,s.CreationDate
       ,s.CreatedInAgencyId
       ,s.CreatedBy AS LastUpdatedBy
       ,s.CreationDate AS LastUpdatedOn
       ,us.Name AS LastUpdatedByName
       ,'C24' Type
       ,ict.Description AS Description
      FROM InsuranceMonthlyPayment s
      INNER JOIN Users us
        ON s.LastUpdatedBy = us.UserId
      INNER JOIN InsuranceCommissionType ict
        ON s.InsuranceCommissionTypeId = ict.InsuranceCommissionTypeId
      WHERE (CAST(s.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
      OR @CreationDate IS NULL)
      AND s.CreatedInAgencyId = @AgencyId
      AND (s.CreatedBy = @UserId
      OR @UserId IS NULL)
      AND s.CardFee IS NOT NULL
      AND s.CardFee > 0
      AND ict.Code = 'C02'
      GROUP BY s.InsuranceMonthlyPaymentId
              ,s.MonthlyPaymentServiceFee
              ,s.Usd
              ,s.CardFee
              ,s.CreatedBy
              ,s.CreationDate
              ,s.CreatedInAgencyId
              ,us.Name
              ,ict.Description

      UNION ALL
      SELECT
        0 CardPaymentId
       ,ISNULL(s.Usd, 0) + ISNULL(s.RegistrationReleaseSOSFee, 0) Usd

        --       ,ISNULL(s.RegistrationReleaseSOSFee, 0) Usd
       ,'' DescriptionParentCitySticker
       ,ISNULL(s.CardFee, 0) Fee
       ,0 FeeUsd
       ,0 TotalPay
       ,COUNT(*) NumberPayments
       ,CAST(0 AS BIT) Batch
       ,s.CreatedBy
       ,s.CreationDate
       ,s.CreatedInAgencyId
       ,s.CreatedBy AS LastUpdatedBy
       ,s.CreationDate AS LastUpdatedOn
       ,us.Name AS LastUpdatedByName
       ,'C25' Type
       ,'registration_release_sos' AS Description
      FROM InsuranceRegistration s
      INNER JOIN Users us
        ON s.LastUpdatedBy = us.UserId
      WHERE (CAST(s.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
      OR @CreationDate IS NULL)
      AND s.CreatedInAgencyId = @AgencyId
      AND (s.CreatedBy = @UserId
      OR @UserId IS NULL)
      AND s.CardFee IS NOT NULL
      AND s.CardFee > 0
      GROUP BY s.InsuranceRegistrationId
              ,s.RegistrationReleaseSOSFee
              ,s.Usd
              ,s.CardFee
              ,s.CreatedBy
              ,s.CreationDate
              ,s.CreatedInAgencyId
              ,us.Name) Queryp
  END;














GO