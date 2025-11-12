SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Updated by jt/15-06-2025  Add new module LEAVE HOURS

CREATE PROCEDURE [dbo].[sp_GetAllPayrollUsersSumByEmployee] (
@StartingDate DATETIME,
@EndingDate DATETIME,
@CashierId INT = NULL,
@AgencyId INT = NULL,
@SearchByRangePeriod BIT = NULL)
AS
BEGIN


SELECT
  dbo.fn_CalculateFractionToTimeString(SUM(RegularHours)) AS sumRegularHoursFormatTime
 ,dbo.fn_CalculateFractionToTimeString(SUM(OvertimeHours)) AS sumOverTimeHoursFormatTime
 ,dbo.fn_CalculateFractionToTimeString(SUM(VacationHours)) AS sumVacationHoursFormatTime
  ,dbo.fn_CalculateFractionToTimeString(SUM(LeaveHours)) AS sumLeaveHoursFormatTime

 ,CAST(SUM(RegularHours) AS DECIMAL(18, 2)) AS sumRegularHours
 ,CAST(SUM(RegularHoursUsd) AS DECIMAL(18, 2)) AS sumRegularHoursUsd
 ,CAST(SUM(OvertimeHours) AS DECIMAL(18, 2)) AS sumOverTimeHours
 ,CAST(SUM(VacationHoursUsd) AS DECIMAL(18, 2)) AS sumVacationHoursUsd
  ,CAST(SUM(LeaveHoursUsd) AS DECIMAL(18, 2)) AS sumLeaveHoursUsd

 ,CAST(SUM(TotalPayment) AS DECIMAL(18, 2)) AS sumTotalToPay
 ,ISNULL(SUM(HoursPromedial), 0) sumHoursPromedial
 ,ISNULL(SUM(Taxes), 0) AS sumTotalTaxes
 ,ISNULL(SUM(EmployeeTaxes), 0) AS sumTotalEmployeeTaxes
 ,ISNULL(SUM(ADP), 0) AS sumAdpUsd
 ,ISNULL(SUM(Cash), 0) AS sumCash
 ,ISNULL(SUM(Others), 0) AS sumOthers
 ,CAST(SUM(OvertimeHoursUsd) AS DECIMAL(18, 2)) AS sumOverTimeHoursUsd
 ,CAST(SUM(VacationHours) AS DECIMAL(18, 2)) AS sumVacationHours
  ,CAST(SUM(LeaveHours) AS DECIMAL(18, 2)) AS sumLeaveHours

 ,CAST(SUM(PayNet) AS DECIMAL(18, 2)) AS sumTotalPayNet
FROM [dbo].[FN_GetPayrollPaymentsData](@StartingDate, @EndingDate, @CashierId, @AgencyId, @SearchByRangePeriod)



END
GO