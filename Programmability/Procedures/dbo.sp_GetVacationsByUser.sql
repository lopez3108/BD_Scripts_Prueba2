SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Last update by jt/30-07-2024  Format VacationsTakeTime
-- date 21-05-2025 task 6487 MODULO SICK HOURS - ADJUSTMENT PAID SICK TIME JF
-- date 03-06-2025 task 6488 Error con los pagos de sick hours JF
CREATE PROCEDURE [dbo].[sp_GetVacationsByUser] @DateFrom DATETIME = NULL,
@DateTo DATETIME = NULL,
@UserId INT,
@Paid BIT = NULL
AS

BEGIN

  SELECT
EmployeeVacationsId,
    UserId
   ,SUM(Hours) Hours
   ,CreationDate
   ,CreatedBy
   ,CycleDateVacation
   ,ISNULL(HourlyRate,0) HourlyRate
   ,ISNULL(UsdPaid,0) UsdPaid
   ,RequiredBy
   ,PaymentDate
   ,PaymentBy
   ,FileName
   ,FORMAT(CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CreationDateFormat
   ,dbo.fn_CalculateFractionToTimeString(SUM(Hours)) AS VacationsTakeTime
   ,FORMAT(CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CreationDateFormat
   ,FORMAT(CycleDateVacation, 'MM-dd-yyyy', 'en-US') CycleDateVacationFormat
   ,FORMAT(DATEADD(DAY, -1, DATEADD(YEAR, 1, CycleDateVacation)), 'MM-dd-yyyy', 'en-US') CycleDateVacationToFormat
   ,FORMAT(PaymentDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') PaymentDateFormat

  FROM fnu_GetVacationsByUser(@DateFrom, @DateTo, @UserId, @Paid)
  GROUP BY UserId
          ,CreationDate
          ,CreatedBy
          ,CycleDateVacation
          ,HourlyRate
          ,UsdPaid
          ,RequiredBy
          ,PaymentDate
          ,PaymentBy,EmployeeVacationsId
          ,FileName


END
GO