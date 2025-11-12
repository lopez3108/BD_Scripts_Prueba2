SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Last update by JT/19-09-2024 Task 6060
--Last update by JT/22-08-2024 Task 6060
--Last update by JT/22-08-2024 Revisión lógica payroll cuando es por salario task 6009
--Updated by jt/15-06-2025  Add new module LEAVE HOURS
-- 2025-08-02 DJ/6690: Modulo Payroll debe mostrar Cashiers con Sick hours o Leave hours por pagar

CREATE   FUNCTION [dbo].[FN_GetInfoPayrollUsers] (@StartDate DATETIME,
@PaymentPeriod VARCHAR(10),
@EndingDate DATETIME)
RETURNS @result TABLE (
  UserId INT
 ,CashierId INT
 ,CycleDateVacation DATETIME
  ,CycleDateLeaveHours DATETIME
 ,OthersDetails INT
 ,Others VARCHAR(100)
 ,PaymentType VARCHAR(10)
 ,Salary VARCHAR(40)
 ,SalaryUsd DECIMAL(18, 2)
 ,Name VARCHAR(80)
 ,RealRegularHours DECIMAL(18, 2)
 ,RegularHours DECIMAL(18, 4)
 ,RealRegularHoursUsd DECIMAL(18, 2)
 ,RegularHoursUsd DECIMAL(18, 2)
 ,OverTimeHours DECIMAL(18, 2)
 ,OverTimeHoursUsd DECIMAL(18, 2)
 ,VacationHours DECIMAL(18, 2)
 ,VacationHoursUsd DECIMAL(18, 2)
  ,LeaveHours DECIMAL(18, 2)
 ,LeaveHoursUsd DECIMAL(18, 2)
 ,Missing DECIMAL(18, 2)
 ,HoursPromedial DECIMAL(18, 2)
 ,TotalToPay DECIMAL(18, 2)
 ,TotalToPaySaved DECIMAL(18, 2)
 ,RegularHoursFormatTime VARCHAR(10)
 ,OverTimeHoursFormatTime VARCHAR(10)
 ,VacationHoursFormatTime VARCHAR(10)
  ,LeaveHoursFormatTime VARCHAR(10)
 ,PaymentTypeNum INT
 ,StartDate DATETIME
 ,EndingDate DATETIME
 ,MissingHoursWork BIT
)
AS
BEGIN
INSERT INTO @result
  SELECT
    UserId
   ,CashierId
   ,CycleDateVacation
   ,CycleDateLeaveHours
   ,OthersDetails
   ,Others
   ,PaymentType
   ,Salary
   ,SalaryUsd
   ,UPPER([Name]) [Name]
   ,RegularHours
   ,CAST(RegularHours AS DECIMAL(18, 2)) AS RegularHours
   ,RealRegularHoursUsd

    --     ,RegularHoursUsd
   ,CASE PaymentType
      WHEN 'HOURLY' THEN RegularHoursUsd
      WHEN 'SALARY' THEN RegularHours * RegularHoursUsd
    END
    AS RegularHoursUsd
   ,CAST(OverTimeHours AS DECIMAL(18, 2)) AS OverTimeHours
    --     ,CASE PaymentType
    --        WHEN 'SALARY' THEN OverTimeHours
    --        WHEN 'HOURLY' THEN OverTimeHoursUsd
    --      END AS OverTimeHoursUsd
   ,CAST(OverTimeHoursUsd AS DECIMAL(18, 2)) AS OverTimeHoursUsd

   ,CAST(VacationHours AS DECIMAL(18, 2)) AS VacationHours
    --     ,(ISNULL(VacationHours, 0)) * ((ISNULL(RegularHoursUsd, 0)))

   ,CASE PaymentType
      WHEN 'SALARY' THEN (ISNULL(VacationHours, 0)) * ((ISNULL(RegularHoursUsd, 0)))
      WHEN 'HOURLY' THEN (ISNULL(VacationHours, 0)) * ((ISNULL(SalaryUsd, 0)))
    END AS VacationHoursUsd

   ,CAST(LeaveHours AS DECIMAL(18, 2)) AS LeaveHours
   ,CASE PaymentType
      WHEN 'SALARY' THEN (ISNULL(LeaveHours, 0)) * ((ISNULL(RegularHoursUsd, 0)))
      WHEN 'HOURLY' THEN (ISNULL(LeaveHours, 0)) * ((ISNULL(SalaryUsd, 0)))
    END AS LeaveHoursUsd

   ,Missing
   ,ISNULL(CAST(ISNULL(HoursPromedial, 0) AS DECIMAL(18, 2)), 0) HoursPromedial
   ,CASE PaymentType
      WHEN 'HOURLY' THEN CAST(((RegularHoursUsd + OverTimeHoursUsd + (ISNULL(VacationHours, 0) * (ISNULL(SalaryUsd, 0)))) + (ISNULL(LeaveHours, 0) * (ISNULL(SalaryUsd, 0)))) AS DECIMAL(18, 2))
      WHEN 'SALARY' THEN CAST(ABS(SalaryUsd) + (ISNULL(VacationHours, 0) * (ISNULL(RegularHoursUsd, 0))) + (ISNULL(LeaveHours, 0) * (ISNULL(RegularHoursUsd, 0))) AS DECIMAL(18, 2))
    END AS TotalToPay
   ,CASE PaymentType
      WHEN 'HOURLY' THEN CAST(((RegularHoursUsd + OverTimeHoursUsd + (ISNULL(VacationHours, 0) * (ISNULL(SalaryUsd, 0))) + (ISNULL(LeaveHours, 0) * (ISNULL(SalaryUsd, 0))))) AS DECIMAL(18, 2))
      WHEN 'SALARY' THEN CAST(ABS(SalaryUsd) + (ISNULL(VacationHours, 0) * (ISNULL(RegularHoursUsd, 0))) + (ISNULL(LeaveHours, 0) * (ISNULL(RegularHoursUsd, 0))) AS DECIMAL(18, 2))
    END AS TotalToPaySaved
   ,[dbo].fn_CalculateFractionToTimeString(RegularHours) AS RegularHoursFormatTime
   ,[dbo].fn_CalculateFractionToTimeString(OverTimeHours) AS OverTimeHoursFormatTime
   ,[dbo].fn_CalculateFractionToTimeString(VacationHours) AS VacationHoursFormatTime
   ,[dbo].fn_CalculateFractionToTimeString(LeaveHours) AS LeaveHoursFormatTime
   ,CASE PaymentType
      WHEN 'HOURLY' THEN 1
      WHEN 'SALARY' THEN 2
    END AS PaymentTypeNum
   ,@StartDate StartDate
   ,@EndingDate EndingDate
   ,CASE PaymentType
      WHEN 'HOURLY' THEN 0
      WHEN 'SALARY' THEN CASE
          WHEN RegularHours < HoursPromedial THEN 1
          ELSE 0
        END
    END AS MissingHoursWork
  FROM (SELECT
      q.UserId
     ,q.CashierId
     ,q.CycleDateVacation
     ,q.CycleDateLeaveHours
     ,NULL OthersDetails
     ,'0.00' Others
     ,q.PaymentType
     ,CONVERT(VARCHAR, CAST(q.USD AS MONEY), 1) + ' (' + q.PaymentType + ')' AS Salary
     ,CAST(q.USD AS VARCHAR(100)) SalaryUsd
     ,q.Name
     ,ISNULL(SUM(q.RegularHours), 0) AS RealRegularHours
     ,CASE @PaymentPeriod
        WHEN 'WEEKLY' THEN CASE
            WHEN ISNULL(SUM(q.RegularHours), 0) > 40 THEN 40
            ELSE ISNULL(SUM(q.RegularHours), 0)
          END
        WHEN '15 DAYS' THEN CASE
            WHEN ISNULL(SUM(q.RegularHours), 0) > 80 THEN 80
            ELSE ISNULL(SUM(q.RegularHours), 0)
          END
        WHEN 'MONTLY' THEN CASE
            WHEN ISNULL(SUM(q.RegularHours), 0) > 160 THEN 160
            ELSE ISNULL(SUM(q.RegularHours), 0)
          END
      END AS RegularHours -- si sobrepasa las horas por periodo (40-80-160) devolvera las misma horas del periodo, si no el valor exacto.
     ,(ROUND(ISNULL(SUM(q.RegularHours), 0), 2) * ISNULL(q.USD, 0)) AS RealRegularHoursUsd
     ,CASE @PaymentPeriod
        WHEN 'WEEKLY' THEN CASE q.PaymentType
            WHEN 'HOURLY' THEN CASE
                WHEN ISNULL(SUM(q.RegularHours), 0) > 40 THEN ISNULL(q.USD, 0) * 40
                ELSE (ROUND(ISNULL(SUM(q.RegularHours), 0), 2) * ISNULL(q.USD, 0))
              END
            ELSE ISNULL((q.USD), 0) / HoursPromedial
          END
        WHEN '15 DAYS' THEN CASE q.PaymentType
            WHEN 'HOURLY' THEN CASE
                WHEN ISNULL(SUM(q.RegularHours), 0) > 80 THEN ISNULL(q.USD, 0) * 80
                ELSE (ROUND(ISNULL(SUM(q.RegularHours), 0), 2) * ISNULL(q.USD, 0))
              END
            ELSE ISNULL((q.USD), 0) / HoursPromedial
          END
        WHEN 'MONTLY' THEN CASE q.PaymentType
            WHEN 'HOURLY' THEN CASE
                WHEN ISNULL(SUM(q.RegularHours), 0) > 160 THEN ISNULL(q.USD, 0) * 160
                ELSE (ROUND(ISNULL(SUM(q.RegularHours), 0), 2) * ISNULL(q.USD, 0))
              END
            ELSE ISNULL((q.USD), 0) / HoursPromedial
          END
      END AS RegularHoursUsd -- Valor (hourly, salary) * horas (40-80-160)  = valorRegularHoras
     ,CASE @PaymentPeriod
        WHEN 'WEEKLY' THEN CASE q.PaymentType
            WHEN 'HOURLY' THEN CASE
                WHEN ISNULL(SUM(q.RegularHours), 0) > 40 THEN ISNULL(ROUND(CAST(SUM(q.RegularHours) - 40 AS FLOAT), 2), 0)
                ELSE 0
              END
            ELSE CASE
                WHEN ISNULL(SUM(q.RegularHours), 0) > HoursPromedial THEN ISNULL(ROUND(CAST(SUM(q.RegularHours) - HoursPromedial AS FLOAT), 2), 0)
                ELSE 0
              END
          END
        WHEN '15 DAYS' THEN CASE q.PaymentType
            WHEN 'HOURLY' THEN CASE
                WHEN SUM(q.RegularHours) > 80 THEN ISNULL(ROUND(CAST(SUM(q.RegularHours) - 80 AS FLOAT), 2), 0)
                ELSE 0
              END
            ELSE CASE
                WHEN ISNULL(SUM(q.RegularHours), 0) > HoursPromedial THEN ISNULL(ROUND(CAST(SUM(q.RegularHours) - HoursPromedial AS FLOAT), 2), 0)
                ELSE 0
              END
          END
        WHEN 'MONTLY' THEN CASE q.PaymentType
            WHEN 'HOURLY' THEN CASE
                WHEN SUM(q.RegularHours) > 160 THEN ISNULL(ROUND(CAST(SUM(q.RegularHours) - 160 AS FLOAT), 2), 0)
                ELSE 0
              END
            ELSE CASE
                WHEN ISNULL(SUM(q.RegularHours), 0) > HoursPromedial THEN ISNULL(ROUND(CAST(SUM(q.RegularHours) - HoursPromedial AS FLOAT), 2), 0)
                ELSE 0
              END
          END
      END AS OverTimeHours --si sobrepasa horas (40-80-160), se restan esas mismas horas a las horas trabajadas (RegularHours), si no, no hay overtime hours
     ,CASE @PaymentPeriod
        WHEN 'WEEKLY' THEN CASE q.PaymentType
            WHEN 'HOURLY' THEN CASE
                WHEN ISNULL(SUM(q.RegularHours), 0) > 40 THEN ROUND((ROUND(ISNULL(SUM(q.RegularHours), 0), 2) - 40) * ISNULL(q.USD, 0), 2) + ROUND(((ROUND(ISNULL(SUM(q.RegularHours), 0), 2) - 40) * ISNULL(q.USD, 0) / 2), 2)
                ELSE 0
              END
            ELSE CASE
                WHEN SUM(q.RegularHours) > HoursPromedial THEN ROUND((ROUND(ISNULL(SUM(q.RegularHours), 0), 2) - HoursPromedial) * ISNULL((q.USD), 0) / HoursPromedial, 2)
                ELSE 0
              END
          END
        WHEN '15 DAYS' THEN CASE q.PaymentType
            WHEN 'HOURLY' THEN CASE
                WHEN SUM(q.RegularHours) > 80 THEN ROUND((ROUND(ISNULL(SUM(q.RegularHours), 0), 2) - 80) * ISNULL(q.USD, 0), 2) + ROUND(((ROUND(ISNULL(SUM(q.RegularHours), 0), 2) - 80) * ISNULL(q.USD, 0) / 2), 2)
                ELSE 0
              END
            ELSE CASE
                WHEN SUM(q.RegularHours) > HoursPromedial THEN ROUND((ROUND(ISNULL(SUM(q.RegularHours), 0), 2) - HoursPromedial) * ISNULL((q.USD), 0) / HoursPromedial, 2)
                ELSE 0
              END
          END
        WHEN 'MONTLY' THEN CASE q.PaymentType
            WHEN 'HOURLY' THEN CASE
                WHEN SUM(q.RegularHours) > 160 THEN ROUND((ROUND(ISNULL(SUM(q.RegularHours), 0), 2) - 160) * ISNULL(q.USD, 0), 2) + ROUND(((ROUND(ISNULL(SUM(q.RegularHours), 0), 2) - 160) * ISNULL(q.USD, 0) / 2), 2)
                ELSE 0
              END
            ELSE CASE
                WHEN SUM(q.RegularHours) > HoursPromedial THEN ROUND((ROUND(ISNULL(SUM(q.RegularHours), 0), 2) - HoursPromedial) * ISNULL((q.USD), 0) / HoursPromedial, 2)
                ELSE 0
              END
          END

      END AS OverTimeHoursUsd --si sobrepasa horas (40-80-160), se restan esas mismas horas a las horas trabajadas (RegularHours) / 2 para devolver el valor de las horas extras, si no, no hay overtime hours

      --       ,CASE @PaymentPeriod
      --          WHEN 'WEEKLY' THEN CASE
      --              WHEN ISNULL(SUM(q.RegularHours), 0) > 40 THEN ISNULL(ROUND(CAST(SUM(q.RegularHours) - 40 AS FLOAT), 2), 0)
      --              ELSE 0
      --            END
      --          WHEN '15 DAYS' THEN CASE
      --              WHEN SUM(q.RegularHours) > 80 THEN ISNULL(ROUND(CAST(SUM(q.RegularHours) - 80 AS FLOAT), 2), 0)
      --              ELSE 0
      --            END
      --          WHEN 'MONTLY' THEN CASE
      --              WHEN SUM(q.RegularHours) > 160 THEN ISNULL(ROUND(CAST(SUM(q.RegularHours) - 160 AS FLOAT), 2), 0)
      --              ELSE 0
      --            END
      --        END AS OverTimeHours --si sobrepasa horas (40-80-160), se restan esas mismas horas a las horas trabajadas (RegularHours), si no, no hay overtime hours
      --       ,CASE @PaymentPeriod
      --          WHEN 'WEEKLY' THEN CASE
      --              WHEN ISNULL(SUM(q.RegularHours), 0) > 40 THEN ROUND((ROUND(ISNULL(SUM(q.RegularHours), 0), 2) - 40) * ISNULL(q.Usd, 0), 2) + ROUND(((ROUND(ISNULL(SUM(q.RegularHours), 0), 2) - 40) * ISNULL(q.Usd, 0) / 2), 2)
      --              ELSE 0
      --            END
      --          WHEN '15 DAYS' THEN CASE
      --              WHEN SUM(q.RegularHours) > 80 THEN ROUND((ROUND(ISNULL(SUM(q.RegularHours), 0), 2) - 80) * ISNULL(q.Usd, 0), 2) + ROUND(((ROUND(ISNULL(SUM(q.RegularHours), 0), 2) - 80) * ISNULL(q.Usd, 0) / 2), 2)
      --              ELSE 0
      --            END
      --          WHEN 'MONTLY' THEN CASE
      --              WHEN SUM(q.RegularHours) > 160 THEN ROUND((ROUND(ISNULL(SUM(q.RegularHours), 0), 2) - 160) * ISNULL(q.Usd, 0), 2) + ROUND(((ROUND(ISNULL(SUM(q.RegularHours), 0), 2) - 160) * ISNULL(q.Usd, 0) / 2), 2)
      --              ELSE 0
      --            END
      --        END AS OverTimeHoursUsd --si sobrepasa horas (40-80-160), se restan esas mismas horas a las horas trabajadas (RegularHours) / 2 para devolver el valor de las horas extras, si no, no hay overtime hours

     ,ISNULL(q.VacationHours, 0) VacationHours
     ,ISNULL(q.LeaveHours, 0) LeaveHours

     ,ISNULL(q.Missing, 0) Missing
     ,ISNULL(CAST(ISNULL(q.HoursPromedial, 0) AS DECIMAL(18, 2)), 0) HoursPromedial
    FROM --- alias q
    (SELECT
        u.USD
       ,u.PaymentType
       ,eve.VacationHours
       ,ele.LeaveHours
       ,dc.Missing
       ,u.Name
       ,u.UserId
       ,ISNULL(CAST(ISNULL(u.HoursPromedial, 0) AS DECIMAL(18, 2)), 0) HoursPromedial
       ,c.CashierId
       ,c.CycleDateVacation
       ,c.CycleDateLeaveHours
       ,CAST(ISNULL(DATEDIFF(SECOND, ts.LoginDate, ts.LogoutDate) / 3600.0, 0) AS DECIMAL(18, 2)) AS RegularHours
      --ROUND(CAST((DATEDIFF(second, ts.LoginDate, ts.LogoutDate) / 60.0) AS FLOAT), 1) AS RegularHours
      FROM Users u
      LEFT JOIN TimeSheet ts
        ON u.UserId = ts.UserId AND CAST(ts.LoginDate AS DATE) >= CAST(@StartDate AS DATE)
      AND CAST(ts.LogoutDate AS DATE) <= CAST(@EndingDate AS DATE)
      INNER JOIN UserTypes ut
        ON ut.UsertTypeId = u.UserType
      INNER JOIN Cashiers c
        ON c.UserId = u.UserId
      LEFT JOIN (SELECT
          ev.UserId
         ,(ISNULL(SUM(ev.Hours), 0) - (SELECT
              ISNULL(SUM(p.VacationHours), 0)
            FROM Payrolls p
            WHERE p.UserId = ev.UserId)
          ) AS VacationHours
        FROM EmployeeVacations ev----------------
        GROUP BY ev.UserId) eve
        ON eve.UserId = u.UserId AND eve.VacationHours > 0

      LEFT JOIN (SELECT
          el.UserId
         ,(ISNULL(SUM(el.Hours), 0) - (SELECT
              ISNULL(SUM(p.LeaveHours), 0)
            FROM Payrolls p
            WHERE p.UserId = el.UserId)
          ) AS LeaveHours
        FROM EmployeeLeaveHours el----------------
        GROUP BY el.UserId) ele
        ON ele.UserId = u.UserId AND ele.LeaveHours > 0
      LEFT JOIN (SELECT
          d.CashierId
         ,SUM(ISNULL(d.Missing, 0)) + SUM(ISNULL(DA.FinalMissing, 0)) AS Missing
        FROM Daily d
        LEFT JOIN DailyAdjustments DA
          ON DA.DailyId = d.DailyId
        WHERE CAST(d.CreationDate AS DATE) >= CAST(@StartDate AS DATE)
        AND CAST(d.CreationDate AS DATE) <= CAST(@EndingDate AS DATE)
        GROUP BY d.CashierId) dc
        ON dc.CashierId = c.CashierId
      WHERE ut.Code = 'Cashier' AND
	  (ele.LeaveHours > 0 OR eve.VacationHours > 0 OR 
	  CAST(ISNULL(DATEDIFF(SECOND, ts.LoginDate, ts.LogoutDate) / 3600.0, 0) AS DECIMAL(18, 2)) > 0)
	  
	  ) AS q

    GROUP BY q.Name
            ,q.USD
            ,q.PaymentType
            ,q.VacationHours
            ,q.LeaveHours
            ,q.UserId
            ,q.CashierId
            ,q.CycleDateVacation
            ,q.CycleDateLeaveHours
            ,q.Missing
            ,q.HoursPromedial) AS QUERYFINAL
RETURN;
END;
GO