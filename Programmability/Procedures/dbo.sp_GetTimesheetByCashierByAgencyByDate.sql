SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetTimesheetByCashierByAgencyByDate] @CashierId INT = NULL,
@DateFrom DATETIME = NULL,
@DateTo DATETIME = NULL,
@StatusCode VARCHAR(4) = NULL,
@AgencyId INT = NULL,
@TimeSheetId INT = NULL
AS
BEGIN   
  SELECT
      dbo.TimeSheet.*
     ,FORMAT(TimeSheet.LoginDate, 'MM-dd-yyyy h:mm:ss tt ', 'en-US') LoginDateFormat
     ,FORMAT(TimeSheet.LogoutDate, 'MM-dd-yyyy h:mm:ss tt ', 'en-US') LogoutDateFormat
     ,FORMAT(TimeSheet.ApprovedOn, 'MM-dd-yyyy h:mm:ss tt ', 'en-US') ApprovedOnFormat
     ,dbo.Agencies.Name AS AgencyName
     ,dbo.Agencies.Code + ' - ' + dbo.Agencies.Name AS AgencyCodeName
     ,dbo.Users.Name AS UserName
     ,FORMAT(CAST(EstimatedDepartureTime AS DATETIME), 'hh:mm tt') EstimatedDepartureTimeFormat
     ,FORMAT(LoginDate, 'dddd') DayWork
     ,dbo.Users.Name
     ,ut.Desciption AS Description
     ,CASE
        WHEN dbo.TimeSheet.LogoutDate IS NULL THEN 0
        ELSE
          --ISNULL(CONVERT(INT, DATEADD(SECOND, DATEDIFF(second,LoginDate,LogOutDate),0), 108),0)
          CAST(ISNULL(DATEDIFF(SECOND, LoginDate, LogoutDate) / 3600.0, 0) AS DECIMAL(18, 7))
      --                       ((DATEDIFF(second, LoginDate, LogOutDate))) / 3600.00
      END AS HoursWorked
     ,CAST(ISNULL(DATEDIFF(SECOND, DATEDIFF(dd, 0, LogoutDate) + CONVERT(DATETIME, EstimatedDepartureTime), LogoutDate) / 3600.0, 0) AS DECIMAL(18, 4)) ExitTimeExceded
     ,ts.Code AS StatusCode
     ,ap.Name AS ApprovedByName,
      FORMAT(CAST(EstimatedDepartureTime AS DATETIME), 'HH:mm') AS EstimatedDepartureTimeHHmm 
   FROM dbo.TimeSheet
    LEFT JOIN dbo.Agencies
      ON dbo.TimeSheet.AgencyId = dbo.Agencies.AgencyId
    INNER JOIN dbo.Users
      ON dbo.TimeSheet.UserId = dbo.Users.UserId
    LEFT JOIN dbo.Users ap
      ON dbo.TimeSheet.ApprovedBy = ap.UserId
    INNER JOIN dbo.Cashiers
      ON dbo.Users.UserId = dbo.Cashiers.UserId
    LEFT JOIN dbo.TimeSheetStatus ts
      ON ts.Id = dbo.TimeSheet.StatusId
    INNER JOIN UserTypes ut
      ON dbo.TimeSheet.Rol = ut.UsertTypeId
      WHERE (@CashierId IS NULL
    OR dbo.Cashiers.CashierId = @CashierId)
    AND (@TimeSheetId IS NULL
    OR dbo.TimeSheet.TimeSheetId = @TimeSheetId)
    AND (CAST(dbo.TimeSheet.LoginDate AS DATE) >= CAST(@DateFrom AS DATE)
    OR @DateFrom IS NULL)
	 AND (CAST(dbo.TimeSheet.LogoutDate AS DATE) <= CAST(@DateTo AS DATE)
    OR @DateTo IS NULL)
    AND (dbo.Agencies.AgencyId = @AgencyId OR @AgencyId IS NULL)
	
	
    END
GO