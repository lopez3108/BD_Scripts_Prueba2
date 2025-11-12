SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- date 16-05-2025 task 6398 Verificación proceso pago de sick hours JF


CREATE PROCEDURE [dbo].[sp_GetPayrollVacationsByUser] @DateFrom DATETIME = NULL,
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
   ,HourlyRate
   ,UsdPaid
   ,RequiredBy
   ,PaymentDate
   ,PaymentBy
   ,FORMAT(CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CreationDateFormat
   ,dbo.fn_CalculateFractionToTimeString(SUM(Hours)) AS VacationsTakeTime
   ,FORMAT(CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CreationDateFormat
   ,FORMAT(CycleDateVacation, 'MM-dd-yyyy', 'en-US') CycleDateVacationFormat
   ,FORMAT(DATEADD(DAY, -1, DATEADD(YEAR, 1, CycleDateVacation)), 'MM-dd-yyyy', 'en-US') CycleDateVacationToFormat
   ,FORMAT(PaymentDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') PaymentDateFormat

  FROM fn_GetPayrollVacationsByUser(@DateFrom, @DateTo, @UserId, @Paid)
  GROUP BY UserId
          ,CreationDate
          ,CreatedBy
          ,CycleDateVacation
          ,HourlyRate
          ,UsdPaid
          ,RequiredBy
          ,PaymentDate
          ,PaymentBy,EmployeeVacationsId


END


GO