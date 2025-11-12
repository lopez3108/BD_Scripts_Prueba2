SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Created by jt/15-06-2025  Add new module LEAVE HOURS
CREATE PROCEDURE [dbo].[sp_GetLeaveHoursPendingByUser] @UserId INT = NULL,
@CycleDateLeaveHours AS DATE = NULL,
--@AccumulateFromBegin BIT = NULL,
@NoAccumulatePreviousCycle BIT = NULL,
@DateFrom DATETIME = NULL,
@DateTo DATETIME = NULL,
@Paid BIT = NULL
AS
BEGIN
SELECT
  CASE
    WHEN LeaveHours <= 0 THEN '0.00'
    ELSE LeaveHours
  END
  AS LeaveHours
 ,dbo.fn_CalculateFractionToTimeString(LeaveHours) AS LeaveHoursTime
 ,CASE
    WHEN PendingLeaveHoursToPay <= 0 OR
      PendingLeaveHoursToPay IS NULL THEN '0.00'
    ELSE PendingLeaveHoursToPay
  END
  AS PendingLeaveHoursToPay
 ,dbo.fn_CalculateFractionToTimeString(PendingLeaveHoursToPay) AS PendingLeaveHoursToPayTime
 ,dbo.fn_CalculateFractionToTimeString(LeaveHours) AS LeaveHoursTime
 ,CASE
    WHEN HoursTaken <= 0 THEN '0.00'
    ELSE FORMAT(HoursTaken, 'N2')
  END
  AS HoursTaken
 ,dbo.fn_CalculateFractionToTimeString(HoursTaken) AS HoursTakenTime
 ,FORMAT(UsdPaid, 'N2') UsdPaid
FROM (SELECT
    CAST([dbo].fnu_CalculateLeaveHours(@UserId, @CycleDateLeaveHours, @NoAccumulatePreviousCycle) AS DECIMAL(18, 2)) AS LeaveHours
   ,(SELECT
        (ISNULL(SUM(ev.Hours), 0) - (SELECT
            ISNULL(SUM(p.LeaveHours), 0)
          FROM Payrolls p
          WHERE p.UserId = ev.UserId)
        ) AS LeaveHours

      FROM EmployeeLeaveHours ev----------------		
      INNER JOIN Users U
        ON ev.UserId = U.UserId
      WHERE U.UserId = @UserId
      GROUP BY ev.UserId)
    AS PendingLeaveHoursToPay --PendingVacationsToPay = Total hours take - total hours pay in any period
   ,ISNULL((SELECT
        SUM(Hours) Hours
      FROM fnu_GetLeaveHoursByUser(@DateFrom, @DateTo, @UserId, NULL))
    , 0)
    AS HoursTaken
   ,ISNULL((SELECT
        SUM(UsdPaid) UsdPaid
      FROM fnu_GetLeaveHoursByUser(@DateFrom, @DateTo, @UserId, NULL))
    , 0)
    AS UsdPaid) AS Q

END;
GO