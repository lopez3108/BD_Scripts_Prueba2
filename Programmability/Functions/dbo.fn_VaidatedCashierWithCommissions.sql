SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Last update by jt/26-09-2024 task 6085 Habilitar comisiones insurance para los cajeros

-- 2024-04-02 felipe/ User Story 5678: Check the cashiers by agency that are related or that have movements

--UPDATET BY : JT/03-03-2024 TASK 5834 List employees commissions only show employees with commission pendings


CREATE FUNCTION [dbo].[fn_VaidatedCashierWithCommissions] (@StartDate DATETIME = NULL,
@EndDate DATETIME = NULL,
@CashierId INT = NULL,
@AgencyId INT,
@OnlyPendings BIT = NULL)
RETURNS BIT

AS
BEGIN
  DECLARE @return AS BIT = 0;


  IF EXISTS (SELECT TOP 1
        p.PhoneSalesId -- Commision Phone Sales	

      FROM PhoneSales p
      INNER JOIN InventoryByAgency i
        ON i.InventoryByAgencyId = p.InventoryByAgencyId
      INNER JOIN Users u
        ON p.CreatedBy = u.UserId
      INNER JOIN Cashiers c
        ON c.UserId = u.UserId
      WHERE (c.CashierId = @CashierId)
      AND (i.AgencyId = @AgencyId)
      AND p.CashierCommission > 0
      AND (@OnlyPendings = 1
      AND (p.ExpenseId <= 0
      OR p.ExpenseId IS NULL)
      OR @OnlyPendings = 0)
      AND (CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
      OR @StartDate IS NULL)
      AND (CAST(CreationDate AS DATE) <= CAST(@EndDate AS DATE)
      OR @EndDate IS NULL))

  BEGIN
    RETURN 1
  END
  ELSE
  IF EXISTS (SELECT TOP 1
        t.TitleId -- Commission Titles  
      FROM Titles t
      INNER JOIN Users u
        ON CreatedBy = u.UserId
      INNER JOIN Cashiers c
        ON c.UserId = u.UserId
      WHERE ProcessAuto = 1
      AND (c.CashierId = @CashierId)
      AND (AgencyId = @AgencyId)
      AND t.CashierCommission > 0
      AND (@OnlyPendings = 1
      AND (t.ExpenseId <= 0
      OR t.ExpenseId IS NULL)
      OR @OnlyPendings = 0)
      AND (CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
      OR @StartDate IS NULL)
      AND (CAST(CreationDate AS DATE) <= CAST(@EndDate AS DATE)
      OR @EndDate IS NULL))
  BEGIN
    RETURN 1
  END

  ELSE

  IF EXISTS (SELECT TOP 1
        t.TRPId -- CComissionTrp730	  
      FROM TRP t
      INNER JOIN PermitTypes pt
        ON t.PermitTypeId = pt.PermitTypeId
      INNER JOIN Users u
        ON t.CreatedBy = u.UserId
      INNER JOIN Cashiers c
        ON c.UserId = u.UserId
      WHERE (c.CashierId = @CashierId)
      AND (AgencyId = @AgencyId)
      AND t.CashierCommission > 0
      AND (@OnlyPendings = 1
      AND (t.ExpenseId <= 0
      OR t.ExpenseId IS NULL)
      OR @OnlyPendings = 0)
      AND (CAST(CreatedOn AS DATE) >= CAST(@StartDate AS DATE)
      OR @StartDate IS NULL)
      AND (CAST(CreatedOn AS DATE) <= CAST(@EndDate AS DATE)
      OR @EndDate IS NULL))

  BEGIN
    RETURN 1
  END

  ELSE

  IF EXISTS (SELECT TOP 1
        ci.CityStickerId -- Commission city stickers	  
      FROM dbo.CityStickers ci
      INNER JOIN dbo.Users u
        ON ci.CreatedBy = u.UserId
      INNER JOIN dbo.Cashiers c
        ON c.UserId = u.UserId
      WHERE (c.CashierId = @CashierId)
      AND (AgencyId = @AgencyId)
      AND ci.CashierCommission > 0
      AND (@OnlyPendings = 1
      AND (ci.ExpenseId <= 0
      OR ci.ExpenseId IS NULL)
      OR @OnlyPendings = 0)
      AND (CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
      OR @StartDate IS NULL)
      AND (CAST(CreationDate AS DATE) <= CAST(@EndDate AS DATE)
      OR @EndDate IS NULL))
  BEGIN
    RETURN 1
  END

  ELSE

  IF EXISTS (SELECT TOP 1
        p.PlateStickerId -- Commission plate stickers  
      FROM dbo.PlateStickers p
      INNER JOIN dbo.Users u
        ON CreatedBy = u.UserId
      INNER JOIN dbo.Cashiers c
        ON c.UserId = u.UserId
      WHERE (c.CashierId = @CashierId)
      AND (AgencyId = @AgencyId)
      AND p.CashierCommission > 0
      AND (@OnlyPendings = 1
      AND (p.ExpenseId <= 0
      OR p.ExpenseId IS NULL)
      OR @OnlyPendings = 0)
      AND (CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
      OR @StartDate IS NULL)
      AND (CAST(CreationDate AS DATE) <= CAST(@EndDate AS DATE)
      OR @EndDate IS NULL))

  BEGIN
    RETURN 1
  END

  ELSE

  --  IF EXISTS (SELECT TOP 1
  --        p.PlateStickerId -- Lendify falta implementar cuando se empiece a usar este módulo
  --       FROM dbo.Lendify l
  --      INNER JOIN dbo.LendifyStatus ls
  --        ON l.LendifyStatusId = ls.LendifyStatusId
  --      INNER JOIN dbo.Users u
  --        ON CreatedBy = u.UserId
  --      INNER JOIN dbo.Cashiers c
  --        ON c.UserId = u.UserId
  --      WHERE (c.CashierId = @CashierId)
  --      AND (AgencyId = @AgencyId)
  --      AND p.CashierCommission > 0
  --      AND (p.ExpenseId <= 0
  --      OR l.ExpenseId IS NULL))
  --
  --  BEGIN
  --    RETURN 1
  --  END
  --
  --  ELSE

  IF EXISTS (SELECT TOP 1
        t.TicketId -- Commissions tickets	  
      FROM dbo.Tickets t
      INNER JOIN dbo.Users u
        ON CreatedBy = u.UserId
      INNER JOIN dbo.Cashiers c
        ON c.UserId = u.UserId
      WHERE (c.CashierId = @CashierId)
      AND (AgencyId = @AgencyId)
      AND t.CashierCommission > 0
      AND (@OnlyPendings = 1
      AND (t.ExpenseId <= 0
      OR t.ExpenseId IS NULL)
      OR @OnlyPendings = 0)

      AND (CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
      OR @StartDate IS NULL)
      AND (CAST(CreationDate AS DATE) <= CAST(@EndDate AS DATE)
      OR @EndDate IS NULL))

  BEGIN
    RETURN 1
  END

  ELSE

  IF EXISTS (SELECT TOP 1
        tfsd.TicketFeeServiceId -- Commissions tickets	
      FROM TicketFeeServiceDetails tfsd
      --        ON t.TicketFeeServiceId = tfsd.TicketFeeServiceId
      INNER JOIN dbo.Users us
        ON tfsd.CreatedBy = us.UserId
      INNER JOIN dbo.Cashiers ca
        ON ca.UserId = us.UserId

      WHERE (ca.CashierId = @CashierId)
      AND (tfsd.AgencyId = @AgencyId)
      AND tfsd.CashierCommission > 0
      AND (@OnlyPendings = 1
      AND (tfsd.ExpenseId <= 0
      OR tfsd.ExpenseId IS NULL)
      OR @OnlyPendings = 0)
      AND (CAST(tfsd.CompletedOn AS DATE) >= CAST(@StartDate AS DATE)
      OR @StartDate IS NULL)
      AND (CAST(tfsd.CompletedOn AS DATE) <= CAST(@EndDate AS DATE)
      OR @EndDate IS NULL))
  BEGIN
    RETURN 1
  END
  ELSE

  IF EXISTS (SELECT TOP 1
        p.InsurancePolicyId -- Commission InsurancePolicy
      FROM dbo.InsurancePolicy p
      INNER JOIN dbo.Users u
        ON CreatedBy = u.UserId
      INNER JOIN dbo.Cashiers c
        ON c.UserId = u.UserId
      WHERE (c.CashierId = @CashierId)
      AND (p.CreatedInAgencyId = @AgencyId)
      AND p.CashierCommission > 0
      AND (@OnlyPendings = 1
      AND (p.ExpenseId <= 0
      OR p.ExpenseId IS NULL)
      OR @OnlyPendings = 0)
      AND (CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
      OR @StartDate IS NULL)
      AND (CAST(CreationDate AS DATE) <= CAST(@EndDate AS DATE)
      OR @EndDate IS NULL)
      AND (CAST(p.CreatedByMonthlyPayment AS BIT) = 0
      OR p.CreatedByMonthlyPayment = NULL))

  BEGIN
    RETURN 1
  END

  ELSE

  IF EXISTS (SELECT TOP 1
        p.InsuranceMonthlyPaymentId -- Commission InsuranceMonthlyPayment
      FROM dbo.InsuranceMonthlyPayment p
      INNER JOIN dbo.Users u
        ON CreatedBy = u.UserId
      INNER JOIN dbo.Cashiers c
        ON c.UserId = u.UserId
      WHERE (c.CashierId = @CashierId)
      AND (p.CreatedInAgencyId = @AgencyId)
      AND p.CashierCommission > 0
      AND (@OnlyPendings = 1
      AND (p.ExpenseId <= 0
      OR p.ExpenseId IS NULL)
      OR @OnlyPendings = 0)
      AND (CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
      OR @StartDate IS NULL)
      AND (CAST(CreationDate AS DATE) <= CAST(@EndDate AS DATE)
      OR @EndDate IS NULL))

  BEGIN
    RETURN 1
  END
  ELSE

  IF EXISTS (SELECT TOP 1
        p.InsuranceRegistrationId -- Commission InsuranceRegistration
      FROM dbo.InsuranceRegistration p
      INNER JOIN dbo.Users u
        ON CreatedBy = u.UserId
      INNER JOIN dbo.Cashiers c
        ON c.UserId = u.UserId
      WHERE (c.CashierId = @CashierId)
      AND (p.CreatedInAgencyId = @AgencyId)
      AND p.CashierCommission > 0
      AND (@OnlyPendings = 1
      AND (p.ExpenseId <= 0
      OR p.ExpenseId IS NULL)
      OR @OnlyPendings = 0)
      AND (CAST(CreationDate AS DATE) >= CAST(@StartDate AS DATE)
      OR @StartDate IS NULL)
      AND (CAST(CreationDate AS DATE) <= CAST(@EndDate AS DATE)
      OR @EndDate IS NULL))

  BEGIN
    RETURN 1
  END
  RETURN @return
END;



GO