SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Updated by jt/15-06-2025  Add new module LEAVE HOURS


CREATE PROCEDURE [dbo].[sp_GetAllPayrollUsersSum] @StartDate DATETIME,
@PaymentPeriod VARCHAR(10),
@EndingDate DATETIME
AS
BEGIN

SELECT
  SUM(RegularHours) AS sumRegularHours
 ,[dbo].fn_CalculateFractionToTimeString(SUM(RegularHours)) AS sumRegularHoursFormatTime
 ,[dbo].fn_CalculateFractionToTimeString(SUM(OverTimeHours)) AS sumOverTimeHoursFormatTime
 ,CAST(SUM(RegularHoursUsd) AS DECIMAL(18, 2)) AS sumRegularHoursUsd
 ,CAST(SUM(OverTimeHours) AS DECIMAL(18, 2)) AS sumOverTimeHours
 ,CAST(SUM(OverTimeHoursUsd) AS DECIMAL(18, 2)) AS sumOverTimeHoursUsd
 ,CAST(SUM(VacationHours) AS DECIMAL(18, 2)) AS sumVacationHours
 ,[dbo].fn_CalculateFractionToTimeString(SUM(VacationHours)) AS sumVacationHoursFormatTime
 ,CAST(SUM(VacationHoursUsd) AS DECIMAL(18, 2)) AS sumVacationHoursUsd

 ,CAST(SUM(LeaveHours) AS DECIMAL(18, 2)) AS sumLeaveHours
 ,[dbo].fn_CalculateFractionToTimeString(SUM(LeaveHours)) AS sumLeaveHoursFormatTime
 ,CAST(SUM(LeaveHoursUsd) AS DECIMAL(18, 2)) AS sumLeaveHoursUsd

 ,CAST(SUM(TotalToPay) AS DECIMAL(18, 2)) AS sumTotalToPay
 ,ISNULL(CAST(ISNULL(SUM(HoursPromedial), 0) AS DECIMAL(18, 2)), 0) sumHoursPromedial
FROM dbo.[FN_GetInfoPayrollUsers](@StartDate, @PaymentPeriod, @EndingDate) q -- obtiene informacion  base del payroll
WHERE q.TotalToPay <> 0;

END;
GO