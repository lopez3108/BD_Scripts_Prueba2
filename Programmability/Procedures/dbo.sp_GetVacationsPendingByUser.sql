SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Last update by jt/25-07-2024  ask 5878 Change logic of sick hours
CREATE PROCEDURE [dbo].[sp_GetVacationsPendingByUser] @UserId INT = NULL,
@CycleDateVacation AS DATE = NULL,
--@AccumulateFromBegin BIT = NULL,
@NoAccumulatePreviousCycle BIT = NULL,
@DateFrom DATETIME = NULL,
@DateTo DATETIME = NULL,
@Paid BIT = NULL
AS
BEGIN
  SELECT
    CASE
      WHEN VacationHours <= 0 THEN '0.00'
      ELSE VacationHours
    END
    AS VacationHours
   ,dbo.fn_CalculateFractionToTimeString(VacationHours) AS VacationHoursTime
   ,CASE
      WHEN PendingVacationsToPay <= 0 OR
        PendingVacationsToPay IS NULL THEN '0.00'
      ELSE PendingVacationsToPay
    END
    AS PendingVacationsToPay
   ,dbo.fn_CalculateFractionToTimeString(PendingVacationsToPay) AS PendingVacationsToPayTime
   ,dbo.fn_CalculateFractionToTimeString(VacationHours) AS VacationHoursTime
   ,CASE
      WHEN HoursTaken <= 0 THEN '0.00'
      ELSE FORMAT(HoursTaken, 'N2')
    END
    AS HoursTaken
   ,dbo.fn_CalculateFractionToTimeString(HoursTaken) AS HoursTakenTime
   , FORMAT(UsdPaid, 'N2') UsdPaid
  FROM (SELECT
      CAST([dbo].[CalculateVacations](@UserId, @CycleDateVacation, @NoAccumulatePreviousCycle) AS DECIMAL(18, 2)) AS VacationHours
     ,(SELECT
          (ISNULL(SUM(ev.Hours), 0) - (SELECT
              ISNULL(SUM(p.VacationHours), 0)
            FROM Payrolls p
            WHERE p.UserId = ev.UserId)
          ) AS VacationHours

        FROM EmployeeVacations ev----------------		
        INNER JOIN Users U
          ON ev.UserId = U.UserId
        WHERE U.UserId = @UserId
        GROUP BY ev.UserId)
      AS PendingVacationsToPay --PendingVacationsToPay = Total hours take - total hours pay in any period
     ,ISNULL((SELECT
          SUM(Hours) Hours
        FROM fnu_GetVacationsByUser(@DateFrom, @DateTo, @UserId, NULL))
      , 0)
      AS HoursTaken
      ,ISNULL((SELECT
          SUM(UsdPaid) UsdPaid
        FROM fnu_GetVacationsByUser(@DateFrom, @DateTo, @UserId, NULL))
      , 0)
      AS UsdPaid) AS Q

END;



GO