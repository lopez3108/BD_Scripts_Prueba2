SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Last update by jt/26-09-2024 task 6085 Habilitar comisiones insurance para los cajeros
--Update by: Felipe, date: 6-abril-2024, task:5723 Agreagr fecha inicio para pago de comisiones
-- 2025-01-17 JF/6293: Habilitar comisiones insurance a los cajeros para los nuevos servicios

CREATE PROCEDURE [dbo].[sp_SaveUsersXComissions] @ComissionApplyId INT = NULL,
@CashierId INT,
@ApplyCitySticker BIT = NULL,
@ApplyPlateSticker BIT = NULL,
@ApplyParkingTicket BIT = NULL,
@ApplyParkingTicketCard BIT = NULL,
@ApplyTitlesAndPlates BIT = NULL,
@ApplyTitlesAndPlatesManual BIT = NULL,
@ApplyTrp730 BIT = NULL,
@ApplyFinancing BIT = NULL,
@ApplyTelephones BIT = NULL,
@ApplyNotary BIT = NULL,
@ApplyLendify BIT = NULL,
@ApplyTickets BIT = NULL,

@ApplyNewPolicy BIT = NULL,
@ApplyMonthlyPayment BIT = NULL,
@ApplyRegistrationRelease BIT = NULL,
@ApplyEndorsement BIT = NULL,
@ApplyPolicyRenewal BIT = NULL,

@CreationDateNewPolicy DATETIME = NULL,
@CreationDateMonthlyPayment DATETIME = NULL,
@CreationDateRegistrationRelease DATETIME = NULL,
@CreationDateEndorsement DATETIME = NULL,
@CreationDatePolicyRenewal DATETIME = NULL,


@StartDateNewPolicy DATETIME = NULL,
@StartDateMonthlyPayment DATETIME = NULL,
@StartDateRegistrationRelease DATETIME = NULL,
@StartDateEndorsement DATETIME = NULL,
@StartDatePolicyRenewal DATETIME = NULL,


@CreationDateCitySticker DATETIME = NULL,
@CreationDateTitlesAndPlates DATETIME = NULL,
@CreationDateTrp730 DATETIME = NULL,
@CreationDateTelephones DATETIME = NULL,
@CreationDateLendify DATETIME = NULL,
@CreationDateTickets DATETIME = NULL,
@CreationDatePlateSticker DATETIME = NULL,
@StartDateCitySticker DATETIME = NULL,
@StartDatePlateSticker DATETIME = NULL,
@StartDateTitlesAndPlates DATETIME = NULL,
@StartDateTrp DATETIME = NULL,
@StartDateTelephones DATETIME = NULL,
@StartDateLendify DATETIME = NULL,
@StartDateTickets DATETIME = NULL,
@CreatedByCitySticker INT = NULL,
@CreatedByPlateSticker INT = NULL,
@CreatedByTitlesAndPlates INT = NULL,
@CreatedByTrp INT = NULL,
@CreatedByTelephones INT = NULL,
@CreatedByLendify INT = NULL,
@CreatedByTickets INT = NULL,

@CreatedByNewPolicy INT = NULL,
@CreatedByMonthlyPayment INT = NULL,
@CreatedByRegistrationRelease INT = NULL,
@CreatedByEndorsement INT = NULL,
@CreatedByPolicyRenewal INT = NULL
AS
BEGIN
  IF (@ComissionApplyId IS NULL)
  BEGIN
    INSERT INTO [dbo].CashierApplyComissions (CashierId,
    ApplyCitySticker,
    CreationDateCitySticker,
    ApplyPlateSticker,
    CreationDatePlateSticker,
    ApplyParkingTicket,
    ApplyParkingTicketCard,
    ApplyTitlesAndPlates,
    CreationDateTitlesAndPlates,
    ApplyTitlesAndPlatesManual,
    ApplyTrp730,
    CreationDateTrp730,
    ApplyFinancing,
    ApplyTelephones,
    CreationDateTelephones,
    ApplyNotary,
    ApplyLendify,
    CreationDateLendify,
    ApplyTickets,
    CreationDateTickets,
    StartDateCitySticker,
    StartDatePlateSticker,
    StartDateTitlesAndPlates,
    StartDateTrp,
    StartDateTelephones,
    StartDateLendify,
    StartDateTickets,
    CreatedByCitySticker,
    CreatedByPlateSticker,
    CreatedByTitlesAndPlates,
    CreatedByTrp,
    CreatedByTelephones,
    CreatedByLendify,
    CreatedByTickets,
    ApplyNewPolicy,
    ApplyMonthlyPayment,
    ApplyRegistrationRelease,
    ApplyEndorsement,
    ApplyPolicyRenewal,
    CreationDateNewPolicy,
    CreationDateMonthlyPayment,
    CreationDateRegistrationRelease,
    CreationDateEndorsement,
    CreationDatePolicyRenewal,
    CreatedByNewPolicy,
    CreatedByMonthlyPayment,
    CreatedByRegistrationRelease,
    CreatedByEndorsement,
    CreatedByPolicyRenewal,
    StartDateNewPolicy, 
    StartDateMonthlyPayment,
    StartDateRegistrationRelease,
    StartDateEndorsement,
    StartDatePolicyRenewal   
    )
      VALUES (@CashierId, @ApplyCitySticker, @CreationDateCitySticker, @ApplyPlateSticker, @CreationDatePlateSticker, @ApplyParkingTicket, @ApplyParkingTicketCard, @ApplyTitlesAndPlates, @CreationDateTitlesAndPlates, @ApplyTitlesAndPlatesManual, @ApplyTrp730, @CreationDateTrp730, @ApplyFinancing, @ApplyTelephones, @CreationDateTelephones, @ApplyNotary, @ApplyLendify, @CreationDateLendify, @ApplyTickets, @CreationDateTickets, @StartDateCitySticker, @StartDatePlateSticker, @StartDateTitlesAndPlates, @StartDateTrp, @StartDateTelephones, @StartDateLendify, @StartDateTickets, @CreatedByCitySticker, @CreatedByPlateSticker, @CreatedByTitlesAndPlates, @CreatedByTrp, @CreatedByTelephones, @CreatedByLendify, @CreatedByTickets, @ApplyNewPolicy, @ApplyMonthlyPayment,
      @ApplyRegistrationRelease,@ApplyEndorsement,@ApplyPolicyRenewal, @CreationDateNewPolicy, @CreationDateMonthlyPayment, @CreationDateRegistrationRelease,@CreationDateEndorsement,@CreationDatePolicyRenewal, @CreatedByNewPolicy, @CreatedByMonthlyPayment, @CreatedByRegistrationRelease,@CreatedByEndorsement,@CreatedByPolicyRenewal, @StartDateNewPolicy, @StartDateMonthlyPayment,@StartDateRegistrationRelease,@StartDateEndorsement,@StartDatePolicyRenewal);
  END;
  ELSE
  BEGIN
    UPDATE [dbo].CashierApplyComissions
    SET ApplyCitySticker = @ApplyCitySticker
       ,CreationDateCitySticker = @CreationDateCitySticker
       ,ApplyPlateSticker = @ApplyPlateSticker
       ,CreationDatePlateSticker = @CreationDatePlateSticker
       ,ApplyParkingTicket = @ApplyParkingTicket
       ,ApplyParkingTicketCard = @ApplyParkingTicketCard
       ,ApplyTitlesAndPlates = @ApplyTitlesAndPlates
       ,CreationDateTitlesAndPlates = @CreationDateTitlesAndPlates
       ,ApplyTitlesAndPlatesManual = @ApplyTitlesAndPlatesManual
       ,ApplyTrp730 = @ApplyTrp730
       ,CreationDateTrp730 = @CreationDateTrp730
       ,ApplyFinancing = @ApplyFinancing
       ,ApplyTelephones = @ApplyTelephones
       ,CreationDateTelephones = @CreationDateTelephones
       ,ApplyNotary = @ApplyNotary
       ,ApplyLendify = @ApplyLendify
       ,CreationDateLendify = @CreationDateLendify
       ,ApplyTickets = @ApplyTickets
       ,CreationDateTickets = @CreationDateTickets
       ,CashierId = @CashierId
       ,StartDateCitySticker = @StartDateCitySticker
       ,StartDatePlateSticker = @StartDatePlateSticker
       ,StartDateTitlesAndPlates = @StartDateTitlesAndPlates
       ,StartDateTrp = @StartDateTrp
       ,StartDateTelephones = @StartDateTelephones
       ,StartDateLendify = @StartDateLendify
       ,StartDateTickets = @StartDateTickets
       ,CreatedByCitySticker = @CreatedByCitySticker
       ,CreatedByPlateSticker = @CreatedByPlateSticker
       ,CreatedByTitlesAndPlates = @CreatedByTitlesAndPlates
       ,CreatedByTrp = @CreatedByTrp
       ,CreatedByTelephones = @CreatedByTelephones
       ,CreatedByLendify = @CreatedByLendify
       ,CreatedByTickets = @CreatedByTickets
       ,ApplyNewPolicy = @ApplyNewPolicy
       ,ApplyMonthlyPayment = @ApplyMonthlyPayment
       ,ApplyRegistrationRelease = @ApplyRegistrationRelease
       ,ApplyEndorsement = @ApplyEndorsement
       ,ApplyPolicyRenewal = @ApplyPolicyRenewal
       ,CreationDateNewPolicy = @CreationDateNewPolicy
       ,CreationDateMonthlyPayment = @CreationDateMonthlyPayment
       ,CreationDateRegistrationRelease = @CreationDateRegistrationRelease
       ,CreationDateEndorsement = @CreationDateEndorsement
       ,CreationDatePolicyRenewal = @CreationDatePolicyRenewal
       ,CreatedByNewPolicy = @CreatedByNewPolicy
       ,CreatedByMonthlyPayment = @CreatedByMonthlyPayment
       ,CreatedByRegistrationRelease = @CreatedByRegistrationRelease
       ,CreatedByEndorsement = @CreatedByEndorsement
       ,CreatedByPolicyRenewal = @CreatedByPolicyRenewal
       ,StartDateRegistrationRelease = @StartDateRegistrationRelease
       ,StartDateMonthlyPayment = @StartDateMonthlyPayment
       ,StartDateNewPolicy =@StartDateNewPolicy
       ,StartDateEndorsement =@StartDateEndorsement
       ,StartDatePolicyRenewal =@StartDatePolicyRenewal

    WHERE ComissionApplyId = @ComissionApplyId;
  END;
END;




GO