SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Created by jt/15-06-2025  Add new module LEAVE HOURS

create PROCEDURE [dbo].[sp_GetPayrollLeaveHoursByUser] @DateFrom DATETIME = NULL,
@DateTo DATETIME = NULL,
@UserId INT,
@Paid BIT = NULL
AS

BEGIN

SELECT
  EmployeeLeaveHoursId
 ,UserId
 ,SUM(Hours) Hours
 ,CreationDate
 ,CreatedBy
 ,CycleDateLeaveHours
 ,HourlyRate
 ,UsdPaid
 ,RequiredBy
 ,PaymentDate
 ,PaymentBy
 ,FORMAT(CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CreationDateFormat
 ,dbo.fn_CalculateFractionToTimeString(SUM(Hours)) AS LeaveHoursTakeTime
 ,FORMAT(CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CreationDateFormat
 ,FORMAT(CycleDateLeaveHours, 'MM-dd-yyyy', 'en-US') CycleDateLeaveHoursFormat
 ,FORMAT(DATEADD(DAY, -1, DATEADD(YEAR, 1, CycleDateLeaveHours)), 'MM-dd-yyyy', 'en-US') CycleDateLeaveHoursToFormat
 ,FORMAT(PaymentDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') PaymentDateFormat

FROM fn_GetPayrollLeaveHoursByUser(@DateFrom, @DateTo, @UserId, @Paid)
GROUP BY UserId
        ,CreationDate
        ,CreatedBy
        ,CycleDateLeaveHours
        ,HourlyRate
        ,UsdPaid
        ,RequiredBy
        ,PaymentDate
        ,PaymentBy
        ,EmployeeLeaveHoursId


END
GO