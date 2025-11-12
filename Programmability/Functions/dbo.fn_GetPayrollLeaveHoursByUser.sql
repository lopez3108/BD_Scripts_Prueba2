SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- date 16-05-2025 task 6398 Verificación proceso pago de sick hours JF


CREATE   FUNCTION [dbo].[fn_GetPayrollLeaveHoursByUser] (@DateFrom DATETIME = NULL,
@DateTo DATETIME = NULL,
@UserId INT,
@Paid BIT = NULL)
RETURNS @result TABLE (
  EmployeeLeaveHoursId INT
 ,UserId INT
 ,Hours DECIMAL(18, 2)
 ,CreationDate DATETIME
 ,CreatedBy INT
 ,CycleDateLeaveHours DATE
 ,HourlyRate DECIMAL(18, 2)
 ,UsdPaid DECIMAL(18, 2)
 ,RequiredBy VARCHAR(300)
 ,PaymentDate DATETIME
 ,PaymentBy VARCHAR(300)
)

AS
BEGIN

  INSERT INTO @result

    SELECT
      E.EmployeeLeaveHoursId
     ,E.UserId
     ,SUM(Hours) Hours
     ,CAST(CreationDate AS DATETIME) CreationDate
     ,CreatedBy
     ,E.CycleDateLeaveHours
     ,CASE p.SalaryType
        WHEN 'HOURLY' THEN p.SalaryUsd
        ELSE ISNULL((p.SalaryUsd), 0) / p.HoursPromedial
      END AS HourlyRate
      --     ,p.SalaryUsd HourlyRate
     ,ISNULL(p.SalaryUsd * E.Hours, 0) UsdPaid
     ,ur.Name RequiredBy
     ,p.PaidOn PaymentDate
     ,up.Name PaymentBy
    FROM EmployeeLeaveHours E
    INNER JOIN Users U
      ON E.UserId = U.UserId
    INNER JOIN Users ur
      ON ur.UserId = E.CreatedBy
    LEFT JOIN Payrolls p
      ON E.PayrollId = p.PayrollId
    LEFT JOIN Users up
      ON p.PaidBy = up.UserId
    WHERE U.UserId = @UserId
    AND (@Paid = 1
    AND E.PayrollId IS NOT NULL
    AND E.PayrollId > 0
    OR ((@Paid = 0
    OR @Paid IS NULL) AND E.PayrollId IS NULL ))
    AND ((CAST(E.CreationDate AS DATE) >= CAST(@DateFrom AS DATE)
    OR @DateFrom IS NULL)
    AND (CAST(E.CreationDate AS DATE) <= CAST(@DateTo AS DATE))
    OR @DateTo IS NULL)

    GROUP BY E.UserId
            ,p.SalaryType
            ,p.HoursPromedial
            ,CreationDate
            ,CreatedBy
            ,CycleDateLeaveHours
            ,p.SalaryUsd
            ,p.VacationHoursUsd
            ,ur.Name
            ,p.PaidOn
            ,up.Name
            ,EmployeeLeaveHoursId
            ,E.Hours
    ORDER BY CAST(E.CreationDate AS DATETIME), CAST(CycleDateLeaveHours AS DATE)


  RETURN;
END;
GO