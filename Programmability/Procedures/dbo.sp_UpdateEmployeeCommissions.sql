SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-04-24 Sp New JF/5723: Add start date for commission payment
--10-10-2024 Jt/6085 Add new commissions InsurancePolicy, InsuranceMonthlyPayment, InsuranceRegistration
-- 2025-01-17 JF/6293: Habilitar comisiones insurance a los cajeros para los nuevos servicios

CREATE PROCEDURE [dbo].[sp_UpdateEmployeeCommissions] (@CashierId INT,
@StartDateCitySticker DATE = NULL,
@StartDatePlateSticker DATE = NULL,
@StartDateTitlesAndPlates DATE = NULL,
@StartDateTrp DATE = NULL,
@StartDateTelephones DATE = NULL,
@StartDateLendify DATE = NULL,
@StartDateTickets DATE = NULL,
@StartDateNewPolicy DATE = NULL,
@StartDateMonthlyPayment DATE = NULL,
@StartDateRegistrationRelease DATE = NULL,
@StartDateEndorsement DATE = NULL,
@StartDatePolicyRenewal DATE = NULL)
AS
BEGIN

  DECLARE @userId INT
  SET @userId = (SELECT TOP 1
      UserId
    FROM dbo.Cashiers c
    WHERE c.CashierId = @CashierId)

--#region Create registers, and apply commissions
--Cuando estamos generando un movimiento nuev, entonces se debe consultar si ese cajero y movimiento, aplican para comisio´n 

  --  CitySticker

  UPDATE dbo.CityStickers
  SET CashierCommission = (SELECT
      cs.CitySticker
    FROM ComissionSettings cs)--Assigns the configured commission value
  FROM CityStickers cs
  WHERE (dbo.fn_GetCahierCommissionElsById(@userId, 'C03', CAST(cs.CreationDate AS DATE)) > 0)
  AND --Check that the cashier does apply to the commissions
  (cs.CashierCommission <= 0
  OR cs.CashierCommission IS NULL)
  AND -- Consult information that does not yet have a commission
  cs.CreatedBy = @userId
  AND CAST(cs.CreationDate AS DATE) >= @StartDateCitySticker
  AND @StartDateCitySticker IS NOT NULL --Consult the information from the configured start date to the current date



  -- PlateStickers

  UPDATE dbo.PlateStickers
  SET CashierCommission = (SELECT
      cs.PlateSticker
    FROM ComissionSettings cs)
  FROM PlateStickers ps
  WHERE (dbo.fn_GetCahierCommissionElsById(@userId, 'C04', ps.CreationDate) > 0)
  AND (ps.CashierCommission <= 0
  OR ps.CashierCommission IS NULL)
  AND ps.CreatedBy = @userId
  AND ps.CreationDate >= @StartDatePlateSticker


  -- TitlesAndPlates

  UPDATE dbo.Titles
  SET CashierCommission = (SELECT
      cs.TitlesAndPlates
    FROM ComissionSettings cs)
  FROM Titles t
  WHERE (dbo.fn_GetCahierCommissionElsById(@userId, 'C01', t.CreationDate) > 0)
  AND (t.CashierCommission <= 0
  OR t.CashierCommission IS NULL)
  AND t.CreatedBy = @userId
  AND t.CreationDate >= @StartDateTitlesAndPlates


  -- Trp730

  UPDATE dbo.TRP
  SET CashierCommission = (SELECT
      cs.Trp730
    FROM ComissionSettings cs)
  FROM TRP t
  WHERE (dbo.fn_GetCahierCommissionElsById(@userId, 'C02', t.CreatedOn) > 0)
  AND (t.CashierCommission <= 0
  OR t.CashierCommission IS NULL)
  AND t.CreatedBy = @userId
  AND t.CreatedOn >= @StartDateTrp


  -- Telephones

  UPDATE dbo.PhoneSales
  SET CashierCommission = (SELECT
      cs.Telephones
    FROM ComissionSettings cs)
  FROM PhoneSales ps
  WHERE (dbo.fn_GetCahierCommissionElsById(@userId, 'C12', ps.CreationDate) > 0)
  AND (ps.CashierCommission <= 0
  OR ps.CashierCommission IS NULL)
  AND ps.CreatedBy = @userId
  AND ps.CreationDate >= @StartDateTelephones


  -- Tickets Módulo

  UPDATE dbo.Tickets
  SET CashierCommission = (SELECT
      cs.Tickets
    FROM ComissionSettings cs)
  FROM Tickets t
  WHERE (dbo.fn_GetCahierCommissionElsById(@userId, 'C24', t.CreationDate) > 0)
  AND (t.CashierCommission <= 0
  OR t.CashierCommission IS NULL)
  AND t.CreatedBy = @userId
  AND t.CreationDate >= @StartDateTickets


  -- Tickets New daily

  UPDATE dbo.TicketFeeServiceDetails
  SET CashierCommission = (SELECT
      cs.Tickets
    FROM ComissionSettings cs)
  FROM TicketFeeServiceDetails tfsd
  WHERE (dbo.fn_GetCahierCommissionElsById(@userId, 'C24', tfsd.CompletedOn) > 0)
  AND (tfsd.CashierCommission <= 0
  OR tfsd.CashierCommission IS NULL)
  AND tfsd.CreatedBy = @userId
  AND tfsd.CompletedOn >= @StartDateTickets

  -- NewPolicys
  UPDATE dbo.InsurancePolicy
  SET CashierCommission = (SELECT
      cs.NewPolicy
    FROM ComissionSettings cs)
  FROM InsurancePolicy ps
  WHERE (dbo.fn_GetCahierCommissionElsById(@userId, 'C30', ps.CreationDate) > 0)
  AND (ps.CashierCommission <= 0
  OR ps.CashierCommission IS NULL)
  AND ps.CreatedBy = @userId
  AND ps.CreationDate >= @StartDateNewPolicy 
  AND (CAST(ps.CreatedByMonthlyPayment AS BIT) = 0
  OR ps.CreatedByMonthlyPayment = NULL)

  -- MonthlyPayment
  UPDATE dbo.InsuranceMonthlyPayment
  SET CashierCommission = (SELECT
      cs.MonthlyPayment
    FROM ComissionSettings cs)
  FROM InsuranceMonthlyPayment ps
  WHERE (dbo.fn_GetCahierCommissionElsById(@userId, 'C31', ps.CreationDate) > 0)
  AND (ps.CashierCommission <= 0
  OR ps.CashierCommission IS NULL)
  AND ps.CreatedBy = @userId
  AND ps.CreationDate >= @StartDateMonthlyPayment

  -- RegistrationRelease
  UPDATE dbo.InsuranceRegistration
  SET CashierCommission = (SELECT
      cs.RegistrationRelease
    FROM ComissionSettings cs)
  FROM InsuranceRegistration ps
  WHERE (dbo.fn_GetCahierCommissionElsById(@userId, 'C32', ps.CreationDate) > 0)
  AND (ps.CashierCommission <= 0
  OR ps.CashierCommission IS NULL)
  AND ps.CreatedBy = @userId
  AND ps.CreationDate >= @StartDateRegistrationRelease

  -- endorsement
  UPDATE dbo.InsuranceMonthlyPayment
  SET CashierCommission = (SELECT
      cs.MonthlyPayment
    FROM ComissionSettings cs)
  FROM InsuranceMonthlyPayment ps
  WHERE (dbo.fn_GetCahierCommissionElsById(@userId, 'C33', ps.CreationDate) > 0)
  AND (ps.CashierCommission <= 0
  OR ps.CashierCommission IS NULL)
  AND ps.CreatedBy = @userId
  AND ps.CreationDate >= @StartDateEndorsement

 -- PolicyRenewal
  UPDATE dbo.InsuranceMonthlyPayment
  SET CashierCommission = (SELECT
      cs.MonthlyPayment
    FROM ComissionSettings cs)
  FROM InsuranceMonthlyPayment ps
  WHERE (dbo.fn_GetCahierCommissionElsById(@userId, 'C34', ps.CreationDate) > 0)
  AND (ps.CashierCommission <= 0
  OR ps.CashierCommission IS NULL)
  AND ps.CreatedBy = @userId
  AND ps.CreationDate >= @StartDatePolicyRenewal

  --remover
--endregion
--#region Delete expense and commissions
--Cuando estamos eliminando un expense, entonces se deben poner las comisiones en 0.
--Sabemos que se está eliminando un expenser, por esta validacion cs.CashierCommission IS NOT NULL y   AND (CAST(cs.CreationDate AS DATE) < @StartDateCitySticker  OR @StartDateCitySticker IS NULL)

  --  CitySticker

  UPDATE dbo.CityStickers
  SET CashierCommission = 0--Assigns the configured commission value
  FROM CityStickers cs
  WHERE (cs.CashierCommission > 0
  OR cs.CashierCommission IS NOT NULL)
  AND cs.ExpenseId IS NULL
  AND -- Consult information that does not yet have a commission
  cs.CreatedBy = @userId
  AND (CAST(cs.CreationDate AS DATE) < @StartDateCitySticker
  OR @StartDateCitySticker IS NULL)--Consult the information from the configured start date to the current date


  -- PlateStickers

  UPDATE dbo.PlateStickers
  SET CashierCommission = 0
  FROM PlateStickers ps
  WHERE (ps.CashierCommission > 0
  OR ps.CashierCommission IS NOT NULL)
  AND ps.ExpenseId IS NULL
  AND ps.CreatedBy = @userId
  AND (CAST(ps.CreationDate AS DATE) < @StartDatePlateSticker
  OR @StartDatePlateSticker IS NULL)


  -- TitlesAndPlates

  UPDATE dbo.Titles
  SET CashierCommission = 0
  FROM Titles t
  WHERE (t.CashierCommission > 0
  OR t.CashierCommission IS NOT NULL)
  AND t.ExpenseId IS NULL
  AND t.CreatedBy = @userId
  AND (CAST(t.CreationDate AS DATE) < @StartDateTitlesAndPlates
  OR @StartDateTitlesAndPlates IS NULL)


  -- Trp730

  UPDATE dbo.TRP
  SET CashierCommission = 0
  FROM TRP t
  WHERE (t.CashierCommission > 0
  OR t.CashierCommission IS NOT NULL)
  AND t.ExpenseId IS NULL
  AND t.CreatedBy = @userId
  AND (CAST(t.CreatedOn AS DATE) < @StartDateTrp
  OR @StartDateTrp IS NULL)


  -- Telephones

  UPDATE dbo.PhoneSales
  SET CashierCommission = 0
  FROM PhoneSales ps
  WHERE (ps.CashierCommission > 0
  OR ps.CashierCommission IS NOT NULL)
  AND ps.ExpenseId IS NULL
  AND ps.CreatedBy = @userId
  AND (CAST(ps.CreationDate AS DATE) < @StartDateTelephones
  OR @StartDateTelephones IS NULL)


  -- Tickets Módulo

  UPDATE dbo.Tickets
  SET CashierCommission = 0
  FROM Tickets t
  WHERE (t.CashierCommission > 0
  OR t.CashierCommission IS NOT NULL)
  AND t.ExpenseId IS NULL
  AND t.CreatedBy = @userId
  AND (CAST(t.CreationDate AS DATE) < @StartDateTickets
  OR @StartDateTickets IS NULL)


  -- Tickets New daily

  UPDATE dbo.TicketFeeServiceDetails
  SET CashierCommission = 0
  FROM TicketFeeServiceDetails tfsd
  WHERE (tfsd.CashierCommission > 0
  OR tfsd.CashierCommission IS NOT NULL)
  AND tfsd.ExpenseId IS NULL
  AND tfsd.CreatedBy = @userId
  AND (CAST(tfsd.CompletedOn AS DATE) < @StartDateTickets
  OR @StartDateTickets IS NULL)



  -- New policy

  UPDATE dbo.InsurancePolicy
  SET CashierCommission = 0
  FROM InsurancePolicy insu
  WHERE (insu.CashierCommission > 0
  OR insu.CashierCommission IS NOT NULL)
  AND insu.ExpenseId IS NULL
  AND insu.CreatedBy = @userId
  AND (CAST(insu.CreationDate AS DATE) < @StartDateNewPolicy
  OR @StartDateNewPolicy IS NULL)
  AND (CAST(insu.CreatedByMonthlyPayment AS BIT) = 0
  OR insu.CreatedByMonthlyPayment = NULL)

  --  MonthlyPayment

  UPDATE dbo.InsuranceMonthlyPayment
  SET CashierCommission = 0
  FROM InsuranceMonthlyPayment ip
  INNER JOIN InsuranceCommissionType ict ON ip.InsuranceCommissionTypeId = ict.InsuranceCommissionTypeId
  WHERE (ip.CashierCommission > 0
  OR ip.CashierCommission IS NOT NULL)
  AND ip.ExpenseId IS NULL
  AND ip.CreatedBy = @userId
  AND (CAST(ip.CreationDate AS DATE) < @StartDateMonthlyPayment
  OR @StartDateMonthlyPayment IS NULL) AND ict.Code = 'C04'


  -- InsuranceRegistration

  UPDATE dbo.InsuranceRegistration
  SET CashierCommission = 0
  FROM InsuranceRegistration ir
  WHERE (ir.CashierCommission > 0
  OR ir.CashierCommission IS NOT NULL)
  AND ir.ExpenseId IS NULL
  AND ir.CreatedBy = @userId
  AND (CAST(ir.CreationDate AS DATE) < @StartDateRegistrationRelease
  OR @StartDateRegistrationRelease IS NULL)

 --  endorsement

  UPDATE dbo.InsuranceMonthlyPayment
  SET CashierCommission = 0
  FROM InsuranceMonthlyPayment ip
  INNER JOIN InsuranceCommissionType ict ON ip.InsuranceCommissionTypeId = ict.InsuranceCommissionTypeId
  WHERE (ip.CashierCommission > 0
  OR ip.CashierCommission IS NOT NULL)
  AND ip.ExpenseId IS NULL
  AND ip.CreatedBy = @userId
  AND (CAST(ip.CreationDate AS DATE) < @StartDateEndorsement
  OR @StartDateEndorsement IS NULL) AND ict.Code = 'C03'

 --  PolicyRenewal

  UPDATE dbo.InsuranceMonthlyPayment
  SET CashierCommission = 0
  FROM InsuranceMonthlyPayment ip
  INNER JOIN InsuranceCommissionType ict ON ip.InsuranceCommissionTypeId = ict.InsuranceCommissionTypeId
  WHERE (ip.CashierCommission > 0
  OR ip.CashierCommission IS NOT NULL)
  AND ip.ExpenseId IS NULL
  AND ip.CreatedBy = @userId
  AND (CAST(ip.CreationDate AS DATE) < @StartDatePolicyRenewal
  OR @StartDatePolicyRenewal IS NULL) AND ict.Code = 'C02'


--endregion


END;







GO