SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JT--LASTUPDATEDON:18-08-2024 FILTER BY Sick paid
--LASTUPDATEDBY: Felipe--LASTUPDATEDON:02-11-2023
--Created by jt/05-08-2024 
-- date 21-05-2025 task 6487 MODULO SICK HOURS - ADJUSTMENT PAID SICK TIME JF
-- date 26-05-2025 task 6533 Error calculando sick hours cuando es pago por salario JF


CREATE FUNCTION [dbo].[fnu_GetVacationsByUser] (@DateFrom DATETIME = NULL,
@DateTo DATETIME = NULL,
@UserId INT,
@Paid BIT = NULL)
RETURNS @result TABLE (
  EmployeeVacationsId INT
 ,UserId INT
 ,Hours DECIMAL(18, 2)
 ,CreationDate DATETIME
 ,CreatedBy INT
 ,CycleDateVacation DATE
 ,HourlyRate DECIMAL(18, 2)
 ,UsdPaid DECIMAL(18, 2)
 ,RequiredBy VARCHAR(300)
 ,PaymentDate DATETIME
 ,PaymentBy VARCHAR(300)
 ,FileName VARCHAR(1000)
)

AS
BEGIN

  INSERT INTO @result

    SELECT
      E.EmployeeVacationsId
     ,E.UserId
     ,SUM(Hours) Hours
     ,CAST(CreationDate AS DATETIME) CreationDate
     ,CreatedBy
     ,CycleDateVacation
     ,CASE p.SalaryType
        WHEN 'HOURLY' THEN p.SalaryUsd
        ELSE ISNULL((p.SalaryUsd), 0) / p.HoursPromedial
      END AS HourlyRate
      ,CASE p.SalaryType
        WHEN 'HOURLY' THEN p.SalaryUsd * e.Hours
        ELSE (ISNULL((p.SalaryUsd), 0) / p.HoursPromedial)*e.Hours
      END AS UsdPaid
      --     ,p.SalaryUsd HourlyRate
--     ,ISNULL(p.SalaryUsd * E.Hours, 0) UsdPaid
     ,ur.Name RequiredBy
     ,p.PaidOn PaymentDate
     ,up.Name PaymentBy
     ,E.FileName
    FROM EmployeeVacations E
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
    OR (@Paid = 0
    OR @Paid IS NULL))
    AND ((CAST(E.CreationDate AS DATE) >= CAST(@DateFrom AS DATE)
    OR @DateFrom IS NULL)
    AND (CAST(E.CreationDate AS DATE) <= CAST(@DateTo AS DATE))
    OR @DateTo IS NULL)

    GROUP BY E.UserId
            ,p.SalaryType
            ,p.HoursPromedial
            ,CreationDate
            ,CreatedBy
            ,CycleDateVacation
            ,p.SalaryUsd
            ,p.VacationHoursUsd
            ,ur.Name
            ,p.PaidOn
            ,up.Name
            ,EmployeeVacationsId
            ,E.Hours
            ,E.FileName
    ORDER BY CAST(E.CreationDate AS DATETIME), CAST(CycleDateVacation AS DATE)


  RETURN;
END;





GO