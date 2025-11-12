SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Last update by jt/26-09-2024 task 6085 Habilitar comisiones insurance para los cajeros
CREATE FUNCTION [dbo].[FN_GetComissionsCashier] (@StartDate DATETIME,
@EndingDate DATETIME,
@UserId INT,
@AgencyId INT)
RETURNS @result TABLE (
  ComissionNotary DECIMAL(18, 2)
 ,ComissionNotaryQuantity INT
 ,ComissionTelephones DECIMAL(18, 2)
 ,ComissionTelephonesQuantity INT
 ,ComissionTitlesAndPlates DECIMAL(18, 2)
 ,ComissionTitlesAndPlatesQunatity INT
 ,
  --ComissionTitlesAndPlatesManual         DECIMAL(18, 2),
  --ComissionTitlesAndPlatesManualQunatity INT,
  ComissionTrp730 DECIMAL(18, 2)
 ,ComissionTrpQuantity INT
 ,ComissionFinancing DECIMAL(18, 2)
 ,ComissionFinancingQuantity INT
 ,ComissionCitySticker DECIMAL(18, 2)
 ,ComissionCityStickerQuantity INT
 ,ComissionPlateSticker DECIMAL(18, 2)
 ,ComissionPlateStickerQuantity INT
 ,ComissionParkingTicket DECIMAL(18, 2)
 ,ComissionParkingTicketQuantity INT
 ,ComissionParkingTicketCard DECIMAL(18, 2)
 ,ComissionParkingTicketCardQuantity INT
 ,ComissionLendify DECIMAL(18, 2)
 ,ComissionLendifyQuantity INT
 ,ComissionTickets DECIMAL(18, 2)
 ,ComissionTicketsQuantity INT
 ,ComissionNewPolicy DECIMAL(18, 2)
 ,ComissionNewPolicyQuantity INT
 ,ComissionMonthlyPayment DECIMAL(18, 2)
 ,ComissionMonthlyPaymentQuantity INT
 ,ComissionRegistrationRelease DECIMAL(18, 2)
 ,ComissionRegistrationReleaseQuantity INT
)
AS
BEGIN
  INSERT INTO @result
    SELECT
      (SELECT
          ISNULL(SUM(ISNULL(Quantity, 0)) * ComissionSettings.Notary, 0)
        FROM Notary
        INNER JOIN Users u
          ON Notary.CreatedBy = u.UserId
        INNER JOIN Cashiers c
          ON c.UserId = u.UserId
        --AND CAST(C.ValidComissions AS DATE) < CAST(@EndingDate AS DATE)
        INNER JOIN CashierApplyComissions ca
          ON ca.CashierId = c.CashierId
          AND ca.ApplyNotary = 1
        WHERE (CreatedBy = @UserId)
        AND (AgencyId = @AgencyId)
        AND ((CAST(c.ValidComissions AS DATE) >= CAST(@StartDate AS DATE)
        AND CAST(c.ValidComissions AS DATE) <= CAST(@EndingDate AS DATE)
        AND (CAST(CreationDate AS DATE) >= CAST(c.ValidComissions AS DATE))
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE)))
        OR ((CAST(c.ValidComissions AS DATE) < CAST(@StartDate AS DATE)
        AND CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE))))))
      AS ComissionNotary
     ,(SELECT
          ISNULL(SUM(Quantity), 0)
        FROM Notary
        INNER JOIN Users u
          ON Notary.CreatedBy = u.UserId
        INNER JOIN Cashiers c
          ON c.UserId = u.UserId
        INNER JOIN CashierApplyComissions ca
          ON ca.CashierId = c.CashierId
          AND ca.ApplyNotary = 1
        WHERE (CreatedBy = @UserId)
        AND (AgencyId = @AgencyId)
        AND ((CAST(c.ValidComissions AS DATE) >= CAST(@StartDate AS DATE)
        AND CAST(c.ValidComissions AS DATE) <= CAST(@EndingDate AS DATE)
        AND (CAST(CreationDate AS DATE) >= CAST(c.ValidComissions AS DATE))
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE)))
        OR ((CAST(c.ValidComissions AS DATE) < CAST(@StartDate AS DATE)
        AND CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE))))))
      AS ComissionNotaryQuantity
     ,Telephones * (SELECT
          COUNT(*)
        FROM PhoneSales p
        INNER JOIN InventoryByAgency i
          ON i.InventoryByAgencyId = p.InventoryByAgencyId
        INNER JOIN Users u
          ON p.CreatedBy = u.UserId
        INNER JOIN Cashiers c
          ON c.UserId = u.UserId
        INNER JOIN CashierApplyComissions ca
          ON ca.CashierId = c.CashierId
          AND ca.ApplyTelephones = 1
        WHERE (CreatedBy = @UserId)
        AND (i.AgencyId = @AgencyId)
        AND ((CAST(c.ValidComissions AS DATE) >= CAST(@StartDate AS DATE)
        AND CAST(c.ValidComissions AS DATE) <= CAST(@EndingDate AS DATE)
        AND (CAST(CreationDate AS DATE) >= CAST(c.ValidComissions AS DATE))
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE)))
        OR ((CAST(c.ValidComissions AS DATE) < CAST(@StartDate AS DATE)
        AND CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE))))))
      AS ComissionTelephones
     ,(SELECT
          COUNT(*)
        FROM PhoneSales p
        INNER JOIN InventoryByAgency i
          ON i.InventoryByAgencyId = p.InventoryByAgencyId
        INNER JOIN Users u
          ON CreatedBy = u.UserId
        INNER JOIN Cashiers c
          ON c.UserId = u.UserId
        INNER JOIN CashierApplyComissions ca
          ON ca.CashierId = c.CashierId
          AND ca.ApplyTelephones = 1
        WHERE (CreatedBy = @UserId)
        AND (i.AgencyId = @AgencyId)
        AND ((CAST(c.ValidComissions AS DATE) >= CAST(@StartDate AS DATE)
        AND CAST(c.ValidComissions AS DATE) <= CAST(@EndingDate AS DATE)
        AND (CAST(CreationDate AS DATE) >= CAST(c.ValidComissions AS DATE))
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE)))
        OR ((CAST(c.ValidComissions AS DATE) < CAST(@StartDate AS DATE)
        AND CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE))))))
      AS ComissionTelephonesQuantity
     ,TitlesAndPlates * (SELECT
          COUNT(*)
        FROM Titles t
        INNER JOIN Users u
          ON CreatedBy = u.UserId
        INNER JOIN Cashiers c
          ON c.UserId = u.UserId
        INNER JOIN CashierApplyComissions ca
          ON ca.CashierId = c.CashierId
          AND ca.ApplyTitlesAndPlates = 1
        WHERE ProcessAuto = 1
        AND (CreatedBy = @UserId)
        AND (AgencyId = @AgencyId)
        AND ((CAST(c.ValidComissions AS DATE) >= CAST(@StartDate AS DATE)
        AND CAST(c.ValidComissions AS DATE) <= CAST(@EndingDate AS DATE)
        AND (CAST(CreationDate AS DATE) >= CAST(c.ValidComissions AS DATE))
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE)))
        OR ((CAST(c.ValidComissions AS DATE) < CAST(@StartDate AS DATE)
        AND CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE))))))
      AS ComissionTitlesAndPlates
     ,(SELECT
          COUNT(*)
        FROM Titles
        INNER JOIN Users u
          ON CreatedBy = u.UserId
        INNER JOIN Cashiers c
          ON c.UserId = u.UserId
        INNER JOIN CashierApplyComissions ca
          ON ca.CashierId = c.CashierId
          AND ca.ApplyTitlesAndPlates = 1
        WHERE ProcessAuto = 1
        AND (CreatedBy = @UserId)
        AND (AgencyId = @AgencyId)
        AND ((CAST(c.ValidComissions AS DATE) >= CAST(@StartDate AS DATE)
        AND CAST(c.ValidComissions AS DATE) <= CAST(@EndingDate AS DATE)
        AND (CAST(CreationDate AS DATE) >= CAST(c.ValidComissions AS DATE))
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE)))
        OR ((CAST(c.ValidComissions AS DATE) < CAST(@StartDate AS DATE)
        AND CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE))))))
      AS ComissionTitlesAndPlatesQunatity
     ,Trp730 * (SELECT
          COUNT(*)
        FROM TRP t
        INNER JOIN PermitTypes pt
          ON t.PermitTypeId = pt.PermitTypeId
        INNER JOIN Users u
          ON t.CreatedBy = u.UserId
        INNER JOIN Cashiers c
          ON c.UserId = u.UserId
        INNER JOIN CashierApplyComissions ca
          ON ca.CashierId = c.CashierId
          AND ca.ApplyTrp730 = 1
        WHERE (t.CreatedBy = @UserId)
        AND (AgencyId = @AgencyId)
        --                         AND pt.Code = 'C02'
        AND ((CAST(c.ValidComissions AS DATE) >= CAST(@StartDate AS DATE)
        AND CAST(c.ValidComissions AS DATE) <= CAST(@EndingDate AS DATE)
        AND (CAST(t.CreatedOn AS DATE) >= CAST(c.ValidComissions AS DATE))
        AND (CAST(t.CreatedOn AS DATE) <= CAST(@EndingDate AS DATE)))
        OR ((CAST(c.ValidComissions AS DATE) < CAST(@StartDate AS DATE)
        AND CAST(t.CreatedOn AS DATE) >= CAST(@StartDate AS DATE)
        AND (CAST(t.CreatedOn AS DATE) <= CAST(@EndingDate AS DATE))))))
      AS ComissionTrp730
     ,(SELECT
          COUNT(*)
        FROM TRP t
        INNER JOIN PermitTypes pt
          ON t.PermitTypeId = pt.PermitTypeId
        INNER JOIN Users u
          ON t.CreatedBy = u.UserId
        INNER JOIN Cashiers c
          ON c.UserId = u.UserId
        INNER JOIN CashierApplyComissions ca
          ON ca.CashierId = c.CashierId
          AND ca.ApplyTrp730 = 1
        WHERE (t.CreatedBy = @UserId)
        AND (AgencyId = @AgencyId)
        --                         AND pt.Code = 'C02'
        AND ((CAST(c.ValidComissions AS DATE) >= CAST(@StartDate AS DATE)
        AND CAST(c.ValidComissions AS DATE) <= CAST(@EndingDate AS DATE)
        AND (CAST(t.CreatedOn AS DATE) >= CAST(c.ValidComissions AS DATE))
        AND (CAST(t.CreatedOn AS DATE) <= CAST(@EndingDate AS DATE)))
        OR ((CAST(c.ValidComissions AS DATE) < CAST(@StartDate AS DATE)
        AND CAST(t.CreatedOn AS DATE) >= CAST(@StartDate AS DATE)
        AND (CAST(t.CreatedOn AS DATE) <= CAST(@EndingDate AS DATE))))))
      AS ComissionTrpQuantity
     ,Financing * (SELECT
          COUNT(*)
        FROM Financing
        WHERE (CreatedBy = @UserId)
        AND (AgencyId = @AgencyId)
        AND (CAST(CreatedOn AS DATE) >= CAST(@StartDate AS DATE))
        AND (CAST(CreatedOn AS DATE) <= CAST(@EndingDate AS DATE)))
      AS ComissionFinancing
     ,(SELECT
          COUNT(*)
        FROM Financing
        WHERE (CreatedBy = @UserId)
        AND (AgencyId = @AgencyId)
        AND (CAST(CreatedOn AS DATE) >= CAST(@StartDate AS DATE))
        AND (CAST(CreatedOn AS DATE) <= CAST(@EndingDate AS DATE)))
      AS ComissionFinancingQuantity
     ,
      ------------------------------------------------------------------------------------------------------------------------
      CitySticker * (
        --                    SELECT COUNT(*)
        SELECT
          ISNULL(COUNT(*) * ComissionSettings.CitySticker, 0)
        FROM CityStickers
        INNER JOIN Users u
          ON CreatedBy = u.UserId
        INNER JOIN Cashiers c
          ON c.UserId = u.UserId
        INNER JOIN CashierApplyComissions ca
          ON ca.CashierId = c.CashierId
          AND ca.ApplyCitySticker = 1
        WHERE (CreatedBy = @UserId)
        AND (AgencyId = @AgencyId)
        AND ((CAST(c.ValidComissions AS DATE) >= CAST(@StartDate AS DATE)
        AND CAST(c.ValidComissions AS DATE) <= CAST(@EndingDate AS DATE)
        AND (CAST(CreationDate AS DATE) >= CAST(c.ValidComissions AS DATE))
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE)))
        OR ((CAST(c.ValidComissions AS DATE) < CAST(@StartDate AS DATE)
        AND CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE))))))
      AS ComissionCitySticker
     ,

      -----------------------------------------------------------------------------------------------------------------------
      (SELECT
          COUNT(*)
        FROM CityStickers
        INNER JOIN Users u
          ON CreatedBy = u.UserId
        INNER JOIN Cashiers c
          ON c.UserId = u.UserId
        INNER JOIN CashierApplyComissions ca
          ON ca.CashierId = c.CashierId
          AND ca.ApplyCitySticker = 1
        WHERE (CreatedBy = @UserId)
        AND (AgencyId = @AgencyId)
        AND ((CAST(c.ValidComissions AS DATE) >= CAST(@StartDate AS DATE)
        AND CAST(c.ValidComissions AS DATE) <= CAST(@EndingDate AS DATE)
        AND (CAST(CreationDate AS DATE) >= CAST(c.ValidComissions AS DATE))
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE)))
        OR ((CAST(c.ValidComissions AS DATE) < CAST(@StartDate AS DATE)
        AND CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE))))))
      AS ComissionCityStickerQuantity
     ,PlateSticker * (SELECT
          COUNT(*)
        FROM PlateStickers
        INNER JOIN Users u
          ON CreatedBy = u.UserId
        INNER JOIN Cashiers c
          ON c.UserId = u.UserId
        INNER JOIN CashierApplyComissions ca
          ON ca.CashierId = c.CashierId
          AND ca.ApplyPlateSticker = 1
        WHERE (CreatedBy = @UserId)
        AND (AgencyId = @AgencyId)
        AND ((CAST(c.ValidComissions AS DATE) >= CAST(@StartDate AS DATE)
        AND CAST(c.ValidComissions AS DATE) <= CAST(@EndingDate AS DATE)
        AND (CAST(CreationDate AS DATE) >= CAST(c.ValidComissions AS DATE))
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE)))
        OR ((CAST(c.ValidComissions AS DATE) < CAST(@StartDate AS DATE)
        AND CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE))))))
      AS ComissionPlateSticker
     ,(SELECT
          COUNT(*)
        FROM PlateStickers
        INNER JOIN Users u
          ON CreatedBy = u.UserId
        INNER JOIN Cashiers c
          ON c.UserId = u.UserId
        INNER JOIN CashierApplyComissions ca
          ON ca.CashierId = c.CashierId
          AND ca.ApplyPlateSticker = 1
        WHERE (CreatedBy = @UserId)
        AND (AgencyId = @AgencyId)
        AND ((CAST(c.ValidComissions AS DATE) >= CAST(@StartDate AS DATE)
        AND CAST(c.ValidComissions AS DATE) <= CAST(@EndingDate AS DATE)
        AND (CAST(CreationDate AS DATE) >= CAST(c.ValidComissions AS DATE))
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE)))
        OR ((CAST(c.ValidComissions AS DATE) < CAST(@StartDate AS DATE)
        AND CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE))))))
      AS ComissionPlateStickerQuantity
     ,ParkingTicket * (SELECT
          COUNT(*)
        FROM ParkingTickets
        INNER JOIN Users u
          ON CreatedBy = u.UserId
        INNER JOIN Cashiers c
          ON c.UserId = u.UserId
        INNER JOIN CashierApplyComissions ca
          ON ca.CashierId = c.CashierId
          AND ca.ApplyParkingTicketCard = 1
        WHERE (CreatedBy = @UserId)
        AND (AgencyId = @AgencyId)
        AND ((CAST(c.ValidComissions AS DATE) >= CAST(@StartDate AS DATE)
        AND CAST(c.ValidComissions AS DATE) <= CAST(@EndingDate AS DATE)
        AND (CAST(CreationDate AS DATE) >= CAST(c.ValidComissions AS DATE))
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE)))
        OR ((CAST(c.ValidComissions AS DATE) < CAST(@StartDate AS DATE)
        AND CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE))))))
      AS ComissionParkingTicket
     ,(SELECT
          COUNT(*) AS Quantity
        FROM ParkingTickets
        INNER JOIN Users u
          ON CreatedBy = u.UserId
        INNER JOIN Cashiers c
          ON c.UserId = u.UserId
        INNER JOIN CashierApplyComissions ca
          ON ca.CashierId = c.CashierId
          AND ca.ApplyParkingTicketCard = 1
        WHERE (CreatedBy = @UserId)
        AND (AgencyId = @AgencyId)
        AND ((CAST(c.ValidComissions AS DATE) >= CAST(@StartDate AS DATE)
        AND CAST(c.ValidComissions AS DATE) <= CAST(@EndingDate AS DATE)
        AND (CAST(CreationDate AS DATE) >= CAST(c.ValidComissions AS DATE))
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE)))
        OR ((CAST(c.ValidComissions AS DATE) < CAST(@StartDate AS DATE)
        AND CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE))))))
      AS ComissionParkingTicketQuantity
     ,ParkingTicketCard * (SELECT
          COUNT(*)
        FROM ParkingTicketsCards
        INNER JOIN Users u
          ON CreatedBy = u.UserId
        INNER JOIN Cashiers c
          ON c.UserId = u.UserId
        INNER JOIN CashierApplyComissions ca
          ON ca.CashierId = c.CashierId
          AND ca.ApplyParkingTicketCard = 1
        WHERE (CreatedBy = @UserId)
        AND (AgencyId = @AgencyId)
        AND ((CAST(c.ValidComissions AS DATE) >= CAST(@StartDate AS DATE)
        AND CAST(c.ValidComissions AS DATE) <= CAST(@EndingDate AS DATE)
        AND (CAST(CreationDate AS DATE) >= CAST(c.ValidComissions AS DATE))
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE)))
        OR ((CAST(c.ValidComissions AS DATE) < CAST(@StartDate AS DATE)
        AND CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE))))))
      AS ComissionParkingTicketCard
     ,(SELECT
          COUNT(*) AS Quantity
        FROM ParkingTicketsCards
        INNER JOIN Users u
          ON CreatedBy = u.UserId
        INNER JOIN Cashiers c
          ON c.UserId = u.UserId
        INNER JOIN CashierApplyComissions ca
          ON ca.CashierId = c.CashierId
          AND ca.ApplyParkingTicketCard = 1
        WHERE (CreatedBy = @UserId)
        AND (AgencyId = @AgencyId)
        AND ((CAST(c.ValidComissions AS DATE) >= CAST(@StartDate AS DATE)
        AND CAST(c.ValidComissions AS DATE) <= CAST(@EndingDate AS DATE)
        AND (CAST(CreationDate AS DATE) >= CAST(c.ValidComissions AS DATE))
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE)))
        OR ((CAST(c.ValidComissions AS DATE) < CAST(@StartDate AS DATE)
        AND CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE))))))
      AS ComissionParkingTicketCardQuantity
     ,(SELECT
          (ISNULL(COUNT(l.LendifyId), 0) * (SELECT
              ISNULL(Lendify, 0)
            FROM ComissionSettings)
          ) AS Quantity
        FROM Lendify l
        INNER JOIN LendifyStatus ls
          ON l.LendifyStatusId = ls.LendifyStatusId
        INNER JOIN Users u
          ON l.CreatedBy = u.UserId
        INNER JOIN Cashiers c
          ON c.UserId = u.UserId
        INNER JOIN CashierApplyComissions ca
          ON ca.CashierId = c.CashierId
          AND ca.ApplyLendify = 1
        WHERE ls.Code = 'C02'--Aproved
        AND (l.CreatedBy = @UserId)
        AND (AgencyId = @AgencyId)
        AND ((CAST(c.ValidComissions AS DATE) >= CAST(@StartDate AS DATE)
        AND CAST(c.ValidComissions AS DATE) <= CAST(@EndingDate AS DATE)
        AND (CAST(l.AprovedDate AS DATE) >= CAST(c.ValidComissions AS DATE))
        AND (CAST(l.AprovedDate AS DATE) <= CAST(@EndingDate AS DATE)))
        OR ((CAST(c.ValidComissions AS DATE) < CAST(@StartDate AS DATE)
        AND CAST(l.AprovedDate AS DATE) >= CAST(@StartDate AS DATE)
        AND (CAST(l.AprovedDate AS DATE) <= CAST(@EndingDate AS DATE))))))
      AS ComissionLendify
     ,(SELECT
          (ISNULL(COUNT(l.LendifyId), 0)) AS Quantity
        FROM Lendify l
        INNER JOIN LendifyStatus ls
          ON l.LendifyStatusId = ls.LendifyStatusId
        INNER JOIN Users u
          ON l.CreatedBy = u.UserId
        INNER JOIN Cashiers c
          ON c.UserId = u.UserId
        INNER JOIN CashierApplyComissions ca
          ON ca.CashierId = c.CashierId
          AND ca.ApplyLendify = 1
        WHERE ls.Code = 'C02'--Aproved
        AND (l.CreatedBy = @UserId)
        AND (AgencyId = @AgencyId)
        AND ((CAST(c.ValidComissions AS DATE) >= CAST(@StartDate AS DATE)
        AND CAST(c.ValidComissions AS DATE) <= CAST(@EndingDate AS DATE)
        AND (CAST(l.AprovedDate AS DATE) >= CAST(c.ValidComissions AS DATE))
        AND (CAST(l.AprovedDate AS DATE) <= CAST(@EndingDate AS DATE)))
        OR ((CAST(c.ValidComissions AS DATE) < CAST(@StartDate AS DATE)
        AND CAST(l.AprovedDate AS DATE) >= CAST(@StartDate AS DATE)
        AND (CAST(l.AprovedDate AS DATE) <= CAST(@EndingDate AS DATE))))))
      AS ComissionLendifyQuantity
     ,Tickets * (SELECT
          COUNT(*)
        FROM Tickets
        INNER JOIN Users u
          ON CreatedBy = u.UserId
        INNER JOIN Cashiers c
          ON c.UserId = u.UserId
        INNER JOIN CashierApplyComissions ca
          ON ca.CashierId = c.CashierId
          AND ca.ApplyTickets = 1
        WHERE (CreatedBy = @UserId)
        AND (AgencyId = @AgencyId)
        AND ((CAST(c.ValidComissions AS DATE) >= CAST(@StartDate AS DATE)
        AND CAST(c.ValidComissions AS DATE) <= CAST(@EndingDate AS DATE)
        AND (CAST(CreationDate AS DATE) >= CAST(c.ValidComissions AS DATE))
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE)))
        OR ((CAST(c.ValidComissions AS DATE) < CAST(@StartDate AS DATE)
        AND CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE))))))
      + (
        --SELECT COUNT(*)

        SELECT
          (ISNULL(SUM(Plus) * (SELECT TOP 1
              ISNULL(Tickets, 0)
            FROM ComissionSettings)
          , 0)) AS Quantity
        FROM TicketFeeServices
        INNER JOIN Users u
          ON CreatedBy = u.UserId
        INNER JOIN Cashiers c
          ON c.UserId = u.UserId
        INNER JOIN CashierApplyComissions ca
          ON ca.CashierId = c.CashierId
          AND ca.ApplyTickets = 1
        WHERE (CreatedBy = @UserId)
        AND (AgencyId = @AgencyId)
        AND ((CAST(c.ValidComissions AS DATE) >= CAST(@StartDate AS DATE)
        AND CAST(c.ValidComissions AS DATE) <= CAST(@EndingDate AS DATE)
        AND (CAST(CreationDate AS DATE) >= CAST(c.ValidComissions AS DATE))
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE)))
        OR ((CAST(c.ValidComissions AS DATE) < CAST(@StartDate AS DATE)
        AND CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE))))))
      AS ComissionTickets
     ,(SELECT
          COUNT(*)
        FROM Tickets
        INNER JOIN Users u
          ON CreatedBy = u.UserId
        INNER JOIN Cashiers c
          ON c.UserId = u.UserId
        INNER JOIN CashierApplyComissions ca
          ON ca.CashierId = c.CashierId
          AND ca.ApplyTickets = 1
        WHERE (CreatedBy = @UserId)
        AND (AgencyId = @AgencyId)
        AND ((CAST(c.ValidComissions AS DATE) >= CAST(@StartDate AS DATE)
        AND CAST(c.ValidComissions AS DATE) <= CAST(@EndingDate AS DATE)
        AND (CAST(CreationDate AS DATE) >= CAST(c.ValidComissions AS DATE))
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE)))
        OR ((CAST(c.ValidComissions AS DATE) < CAST(@StartDate AS DATE)
        AND CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE))))))
      +
      ISNULL((SELECT
          SUM(Plus)
        FROM TicketFeeServices
        INNER JOIN Users u
          ON CreatedBy = u.UserId
        INNER JOIN Cashiers c
          ON c.UserId = u.UserId
        INNER JOIN CashierApplyComissions ca
          ON ca.CashierId = c.CashierId
          AND ca.ApplyTickets = 1
        WHERE (CreatedBy = @UserId)
        AND (AgencyId = @AgencyId)
        AND ((CAST(c.ValidComissions AS DATE) >= CAST(@StartDate AS DATE)
        AND CAST(c.ValidComissions AS DATE) <= CAST(@EndingDate AS DATE)
        AND (CAST(CreationDate AS DATE) >= CAST(c.ValidComissions AS DATE))
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE)))
        OR ((CAST(c.ValidComissions AS DATE) < CAST(@StartDate AS DATE)
        AND CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE))))))
      , 0)
      AS ComissionTicketsQuantity
     ,NewPolicy * (SELECT
          COUNT(*)
        FROM InsurancePolicy
        INNER JOIN Users u
          ON CreatedBy = u.UserId
        INNER JOIN Cashiers c
          ON c.UserId = u.UserId
        INNER JOIN CashierApplyComissions ca
          ON ca.CashierId = c.CashierId
          AND ca.ApplyNewPolicy = 1
        WHERE (CreatedBy = @UserId)
        AND (InsurancePolicy.CreatedInAgencyId = @AgencyId)
        AND ((CAST(c.ValidComissions AS DATE) >= CAST(@StartDate AS DATE)
        AND CAST(c.ValidComissions AS DATE) <= CAST(@EndingDate AS DATE)
        AND (CAST(CreationDate AS DATE) >= CAST(c.ValidComissions AS DATE))
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE)))
        OR ((CAST(c.ValidComissions AS DATE) < CAST(@StartDate AS DATE)
        AND CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE))))))
      AS ComissionNewPolicy
     ,(SELECT
          COUNT(*)
        FROM InsurancePolicy
        INNER JOIN Users u
          ON CreatedBy = u.UserId
        INNER JOIN Cashiers c
          ON c.UserId = u.UserId
        INNER JOIN CashierApplyComissions ca
          ON ca.CashierId = c.CashierId
          AND ca.ApplyNewPolicy= 1
        WHERE (CreatedBy = @UserId)
        AND (InsurancePolicy.CreatedInAgencyId = @AgencyId)
        AND ((CAST(c.ValidComissions AS DATE) >= CAST(@StartDate AS DATE)
        AND CAST(c.ValidComissions AS DATE) <= CAST(@EndingDate AS DATE)
        AND (CAST(CreationDate AS DATE) >= CAST(c.ValidComissions AS DATE))
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE)))
        OR ((CAST(c.ValidComissions AS DATE) < CAST(@StartDate AS DATE)
        AND CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE))))))
      AS ComissionNewPolicyQuantity
      ,MonthlyPayment * (SELECT
          COUNT(*)
        FROM InsuranceMonthlyPayment imp
        INNER JOIN Users u
          ON imp.CreatedBy = u.UserId
        INNER JOIN Cashiers c
          ON c.UserId = u.UserId
        INNER JOIN CashierApplyComissions ca
          ON ca.CashierId = c.CashierId
          AND ca.ApplyMonthlyPayment  = 1
        WHERE (imp.CreatedBy = @UserId)
        AND (imp.CreatedInAgencyId = @AgencyId)
        AND ((CAST(c.ValidComissions AS DATE) >= CAST(@StartDate AS DATE)
        AND CAST(c.ValidComissions AS DATE) <= CAST(@EndingDate AS DATE)
        AND (CAST(CreationDate AS DATE) >= CAST(c.ValidComissions AS DATE))
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE)))
        OR ((CAST(c.ValidComissions AS DATE) < CAST(@StartDate AS DATE)
        AND CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE))))))
      AS ComissionMonthlyPayment
     ,(SELECT
          COUNT(*)
        FROM InsuranceMonthlyPayment imp
        INNER JOIN Users u
          ON imp.CreatedBy = u.UserId
        INNER JOIN Cashiers c
          ON c.UserId = u.UserId
        INNER JOIN CashierApplyComissions ca
          ON ca.CashierId = c.CashierId
          AND ca.ApplyMonthlyPayment  = 1
        WHERE (imp.CreatedBy = @UserId)
        AND (imp.CreatedInAgencyId = @AgencyId)
        AND ((CAST(c.ValidComissions AS DATE) >= CAST(@StartDate AS DATE)
        AND CAST(c.ValidComissions AS DATE) <= CAST(@EndingDate AS DATE)
        AND (CAST(CreationDate AS DATE) >= CAST(c.ValidComissions AS DATE))
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE)))
        OR ((CAST(c.ValidComissions AS DATE) < CAST(@StartDate AS DATE)
        AND CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE))))))
      AS ComissionMonthlyPaymentQuantity,
        RegistrationRelease * (SELECT
          COUNT(*)
        FROM InsuranceRegistration ir
        INNER JOIN Users u
          ON ir.CreatedBy = u.UserId
        INNER JOIN Cashiers c
          ON c.UserId = u.UserId
        INNER JOIN CashierApplyComissions ca
          ON ca.CashierId = c.CashierId
          AND ca.ApplyRegistrationRelease  = 1
        WHERE (ir.CreatedBy = @UserId)
        AND (ir.CreatedInAgencyId = @AgencyId)
        AND ((CAST(c.ValidComissions AS DATE) >= CAST(@StartDate AS DATE)
        AND CAST(c.ValidComissions AS DATE) <= CAST(@EndingDate AS DATE)
        AND (CAST(CreationDate AS DATE) >= CAST(c.ValidComissions AS DATE))
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE)))
        OR ((CAST(c.ValidComissions AS DATE) < CAST(@StartDate AS DATE)
        AND CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE))))))
      AS ComissionRegistrationRelease
     ,(SELECT
          COUNT(*)
        FROM InsuranceRegistration ir
        INNER JOIN Users u
          ON ir.CreatedBy = u.UserId
        INNER JOIN Cashiers c
          ON c.UserId = u.UserId
        INNER JOIN CashierApplyComissions ca
          ON ca.CashierId = c.CashierId
          AND ca.ApplyRegistrationRelease  = 1
        WHERE (ir.CreatedBy = @UserId)
        AND (ir.CreatedInAgencyId = @AgencyId)
        AND ((CAST(c.ValidComissions AS DATE) >= CAST(@StartDate AS DATE)
        AND CAST(c.ValidComissions AS DATE) <= CAST(@EndingDate AS DATE)
        AND (CAST(CreationDate AS DATE) >= CAST(c.ValidComissions AS DATE))
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE)))
        OR ((CAST(c.ValidComissions AS DATE) < CAST(@StartDate AS DATE)
        AND CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
        AND (CAST(CreationDate AS DATE) <= CAST(@EndingDate AS DATE))))))
      AS ComissionRegistrationReleaseQuantity

    FROM ComissionSettings;
  RETURN;
END;


GO