SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Last update by JT/16-09-2024 TASK 6060 Salary usd in format money 
-- 2024-05-09 DJ/5813: Paynet column not calculating correctly
--Updated by jt/15-06-2025  Add new module LEAVE HOURS

CREATE   FUNCTION [dbo].[FN_GetPayrollPaymentsData] (@StartingDate DATETIME,
@EndingDate DATETIME,
@CashierId INT = NULL,
@AgencyId INT = NULL,
@SearchByRangePeriod BIT = NULL)
RETURNS @result TABLE (
  CreationDateFormat VARCHAR(20)
 ,ToDateFormat VARCHAR(20)
 ,PayrollId INT
 ,UserId INT
 ,FromDate DATETIME
 ,ToDate DATETIME
 ,RegularHours DECIMAL(18, 2)
 ,RegularHoursFormatTime VARCHAR(20)
 ,RegularHoursUsd DECIMAL(18, 2)
 ,OvertimeHours DECIMAL(18, 2)
 ,OvertimeHoursFormatTime VARCHAR(20)
 ,OvertimeHoursUsd DECIMAL(18, 2)
 ,VacationHours DECIMAL(18, 2)
 ,VacationHoursFormatTime VARCHAR(20)
 ,VacationHoursUsd DECIMAL(18, 2)

 ,LeaveHours DECIMAL(18, 2)
 ,LeaveHoursFormatTime VARCHAR(20)
 ,LeaveHoursUsd DECIMAL(18, 2)
 ,Missing DECIMAL(18, 2)
 ,Others DECIMAL(18, 2)
 ,TotalPayment DECIMAL(18, 2)
 ,ADP DECIMAL(18, 2)
 ,CASH DECIMAL(18, 2)
 ,Taxes DECIMAL(18, 2)
 ,EmployeeTaxes DECIMAL(18, 2)
 ,PaidOn DATETIME
 ,PaidOnFormat VARCHAR(40)
 ,PaidBy INT
 ,PeriodPayment VARCHAR(15)
 ,HoursPromedial DECIMAL(18, 1)
 ,AgencyId INT
 ,PaymentType VARCHAR(20)
 ,Name VARCHAR(60)
 ,SalaryType VARCHAR(10)
 ,SalaryUsd DECIMAL(18, 2)
 ,Salary VARCHAR(30)
 ,TotalToPay DECIMAL(18, 2)
 ,PayNet DECIMAL(18, 2)

)
AS


BEGIN

  INSERT INTO @result
    SELECT DISTINCT
      FORMAT(P.FromDate, 'MM-dd-yyyy', 'en-US') CreationDateFormat
     ,FORMAT(P.ToDate, 'MM-dd-yyyy', 'en-US') ToDateFormat
     ,P.PayrollId
     ,P.UserId
     ,P.FromDate
     ,P.ToDate
     ,P.RegularHours
     ,dbo.fn_CalculateFractionToTimeString(P.RegularHours) AS RegularHoursFormatTime
     ,P.RegularHoursUsd
     ,P.OvertimeHours
     ,dbo.fn_CalculateFractionToTimeString(P.OvertimeHours) AS OvertimeHoursFormatTime
     ,P.OvertimeHoursUsd
     ,P.VacationHours
     ,dbo.fn_CalculateFractionToTimeString(P.VacationHours) AS VacationHoursFormatTime
     ,P.VacationHoursUsd


     ,P.LeaveHours
     ,dbo.fn_CalculateFractionToTimeString(P.LeaveHours) AS LeaveHoursFormatTime
     ,ISNULL(P.LeaveHoursUsd , 0 )LeaveHoursUsd


     ,P.Missing
     ,P.Others
     ,P.TotalPayment
     ,P.ADP
     ,P.CASH
     ,P.Taxes
     ,ISNULL(P.EmployeeTaxes, 0) AS EmployeeTaxes
     ,P.PaidOn
     ,FORMAT(P.PaidOn, 'MM-dd-yyyy h:mm:ss tt ', 'en-US') PaidOnFormat
     ,P.PaidBy
     ,P.PeriodPayment
     ,P.HoursPromedial
     ,P.AgencyId
     ,P.PaymentType
     ,UPPER(U.Name) [Name]
     ,P.SalaryType
     ,P.SalaryUsd
     ,CONVERT(VARCHAR, CAST(P.SalaryUsd AS MONEY), 1) + ' (' + P.PaymentType + ')' AS Salary

     ,CASE P.PaymentType
        WHEN 'HOURLY' THEN CAST(((P.RegularHoursUsd + P.OvertimeHoursUsd + (ISNULL(P.VacationHours, 0) * (ISNULL(P.SalaryUsd, 0)))) + (ISNULL(P.LeaveHours, 0) * (ISNULL(P.SalaryUsd, 0)))) AS DECIMAL(18, 2))
        WHEN 'SALARY' THEN CAST(ABS(P.SalaryUsd) AS DECIMAL(18, 2))
      END AS TotalToPay
     ,CASE P.PaymentType
        WHEN 'HOURLY' THEN (CAST(((P.RegularHoursUsd + P.OvertimeHoursUsd + (ISNULL(P.VacationHours, 0) * (ISNULL(P.SalaryUsd, 0)))) + (ISNULL(P.LeaveHours, 0) * (ISNULL(P.SalaryUsd, 0)))) AS DECIMAL(18, 2))) - (ISNULL(P.EmployeeTaxes, 0))
        WHEN 'SALARY' THEN CAST(ABS(P.SalaryUsd) AS DECIMAL(18, 2)) - (ISNULL(P.EmployeeTaxes, 0))
      END AS PayNet
    FROM Payrolls P
    INNER JOIN Users U
      ON U.UserId = P.UserId
    INNER JOIN AgenciesxUser AU
      ON AU.UserId = U.UserId
    WHERE ((@SearchByRangePeriod = 1
    AND CAST(P.FromDate AS DATE) >= CAST(@StartingDate AS DATE)
    AND CAST(P.ToDate AS DATE) <= CAST(@EndingDate AS DATE))
    OR (@SearchByRangePeriod = 0
    AND (CAST(P.PaidOn AS DATE) >= CAST(@StartingDate AS DATE)
    AND CAST(P.PaidOn AS DATE) <= CAST(@EndingDate AS DATE))))
    AND ((AU.AgencyId = @AgencyId
    AND @CashierId IS NULL)
    OR ((@CashierId IS NOT NULL
    AND AU.UserId = @CashierId))
    OR (@CashierId IS NULL
    AND @AgencyId IS NULL));
  RETURN;
END;
GO