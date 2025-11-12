SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Updated by jt/15-06-2025  Add new module LEAVE HOURS

CREATE PROCEDURE [dbo].[sp_SavePayroll] (@UserId INT,
@FromDate DATETIME,
@ToDate DATETIME,
@HoursPromedial DECIMAL(18, 2) = NULL,
@RegularHours DECIMAL(18, 2),
@RegularHoursUsd DECIMAL(18, 2),
@OvertimeHours DECIMAL(18, 2),
@OvertimeHoursUsd DECIMAL(18, 2),
@Missing DECIMAL(18, 2),
@Others DECIMAL(18, 2),
@VacationHours DECIMAL(18, 2),
@VacationHoursUsd DECIMAL(18, 2),
@LeaveHours DECIMAL(18, 2),
@LeaveHoursUsd DECIMAL(18, 2),
@TotalPayment DECIMAL(18, 2),
@ADP DECIMAL(18, 2),
@Cash DECIMAL(18, 2),
@Taxes DECIMAL(18, 2),
@EmployeeTaxes DECIMAL(18, 2),
@PaidOn DATETIME,
@PaidBy INT,
@SalaryType VARCHAR(10),
@SalaryUsd DECIMAL(18, 2),
@PeriodPayment VARCHAR(15) = NULL,
@CycleDateVacation DATETIME = NULL,
@CycleDateLeaveHours DATETIME = NULL,
@Response INT OUTPUT,
@AgencyId INT = NULL,
@PaymentType VARCHAR(10) = NULL)
AS
  IF NOT EXISTS (SELECT
        1
      FROM Payrolls
      WHERE UserId = @UserId
      AND ((CAST(@FromDate AS DATE) = CAST(FromDate AS DATE)
      AND CAST(@ToDate AS DATE) = CAST(ToDate AS DATE))
      OR (CAST(@FromDate AS DATE) <= CAST(FromDate AS DATE)
      AND CAST(@ToDate AS DATE) >= CAST(FromDate AS DATE))
      OR (CAST(@FromDate AS DATE) <= CAST(ToDate AS DATE)
      AND CAST(@ToDate AS DATE) >= CAST(ToDate AS DATE))
      OR (CAST(@FromDate AS DATE) <= CAST(FromDate AS DATE)
      AND CAST(@ToDate AS DATE) >= CAST(ToDate AS DATE))))
  BEGIN
    IF (@CycleDateVacation IS NOT NULL) -- se actualiza el cycle date cuando no existe uno anteriormente dentro del cycle date.
    BEGIN
      UPDATE Cashiers
      SET CycleDateVacation = @CycleDateVacation
      WHERE UserId = @UserId;
    END;
      IF (@CycleDateLeaveHours IS NOT NULL) -- se actualiza el cycle date  de las leave hours cuando no existe uno anteriormente dentro del cycle date.
    BEGIN
      UPDATE Cashiers
      SET CycleDateLeaveHours = @CycleDateLeaveHours
      WHERE UserId = @UserId;
    END;
    INSERT INTO [dbo].Payrolls (UserId,
    FromDate,
    ToDate,
    RegularHours,
    RegularHoursUsd,
    OvertimeHours,
    OvertimeHoursUsd,
    Missing,
    Others,
    VacationHours,
    VacationHoursUsd,
    LeaveHours,
    LeaveHoursUsd,
    TotalPayment,
    ADP,
    CASH,
    Taxes,
    EmployeeTaxes,
    PaidOn,
    PaidBy,
    SalaryType,
    SalaryUsd,
    PeriodPayment,
    HoursPromedial,
    AgencyId,
    PaymentType)
      VALUES (@UserId,
      @FromDate, 
      @ToDate, 
      @RegularHours, 
      @RegularHoursUsd,
      @OvertimeHours, 
      @OvertimeHoursUsd, 
      @Missing, 
      @Others,
      @VacationHours, 
      @VacationHoursUsd,
      @LeaveHours, 
      @LeaveHoursUsd,
      @TotalPayment, 
      @ADP,
      @Cash, @Taxes, @EmployeeTaxes, @PaidOn, @PaidBy, @SalaryType, @SalaryUsd, @PeriodPayment, @HoursPromedial, @AgencyId, @PaymentType);
    SET @Response = @@IDENTITY;--Pago ok
  END;
  ELSE
  BEGIN
    SET @Response = 0; --Ya tiene pago en el periodo
  END;
GO