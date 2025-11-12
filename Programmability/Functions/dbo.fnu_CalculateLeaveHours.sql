SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Created by jt/15-06-2025  Add new module LEAVE HOURS

CREATE   FUNCTION [dbo].[fnu_CalculateLeaveHours] (@UserId INT,
@CycleDateLeaveHours AS DATE,
--@AccumulateFromBegin BIT = NULL,
@NoAccumulatePreviousCycles BIT = NULL)
RETURNS DECIMAL(18, 2)
AS
BEGIN
  DECLARE @startVacationHoursAccumulated DECIMAL(18, 2) = 0
         ,@vacationHoursAccumulated DECIMAL(18, 2) = 0
         ,@vacationHoursAccumulatedPreviousCycle DECIMAL(18, 2) = 0
         ,@totalVacationHoursAccumulated DECIMAL(18, 2)
         ,@hoursAvailable DECIMAL(18, 2)
         ,@hoursworked DECIMAL(18, 2)
         ,@hourstaken DECIMAL(18, 2)
         ,@hoursFirstCycle DECIMAL(18, 2)
         ,@FirstPayrollDate AS DATE
         ,@FirstCycleDate AS DATE
         ,@StartingDate AS DATE
         ,@MonthStarting INT
         ,@DayStarting INT
         ,@MonthFromPayroll INT
         ,@DayFromPayroll INT
         ,@IsStartBeforeOrEqualPayroll BIT
         ,@CurrentCycleDateVacationTblUser AS DATE
         ,@result DECIMAL(18, 2) = 0;


--Lógica sick hours:-A cada cajero por cada 35 horas laboradas en un periodo de 12 meses,
-- el sistema le debe generar un hora disponible skck hours. 
--Por ejemplo si el empleado trabajó  en un mes 140 horas / 35 nos daría un valor acumulado de vacaciones =  4 horas

-- -Un empleado puede generar máximo 40 horas en el periodo de 12 meses, si genera las 40 horas antes de terminar el periodo 
--el sistema debe parar  el conteo y esperar hasta que empiece el nuevo ciclo.

--We need to get the info of user
SELECT TOP 1
  @StartingDate = u1.StartingDate
 ,@CurrentCycleDateVacationTblUser = c.CycleDateLeaveHours --This var help us to know the current cycle, this value is update in every cicly when pay the payroll
FROM Cashiers c
INNER JOIN Users u1
  ON c.UserId = u1.UserId
WHERE c.UserId = @UserId

--Third We need to know the accumulated hours in the current cycle
SELECT
  @hoursworked = ISNULL(SUM(DATEDIFF(SECOND, LoginDate, LogoutDate) / 3600.0), 0)
FROM TimeSheet
WHERE UserId = @UserId
AND ((CAST(TimeSheet.LoginDate AS DATE) >= @CycleDateLeaveHours --The vacation hours only apply when the timesheet is greater or equal than the current cycle
AND CAST(TimeSheet.LoginDate AS DATE) >= (SELECT TOP 1 --And The vacation hours Only apply when the cashier has a first 
    --payroll greater than 2024-01-07, and is from  date of this payroll
    CAST(pr.FromDate AS DATE)
  FROM Payrolls pr
  INNER JOIN Users u
    ON pr.UserId = u.UserId
  INNER JOIN Cashiers c
    ON u.UserId = c.UserId
  WHERE u.UserId = @UserId
  AND CAST(PR.FromDate AS DATE) >= CAST('2024-01-07' AS DATE)--"Las LEAVE HOURS (PL) se empiezan a acumular desde el primer payroll pagado después de 07-01-2024".
  ORDER BY CAST(pr.FromDate AS DATE) ASC)
)
AND (CAST(TimeSheet.LoginDate AS DATE) <= DATEADD(DAY, -1, DATEADD(YEAR, 1, @CycleDateLeaveHours))--And the vacation hours only apply to the finish the current cycle
AND (CAST(TimeSheet.LogoutDate AS DATE) <= (SELECT TOP 1 --And The vacation hours Only apply to the last payroll date when we are not pay the payroll 
    CAST(pr.ToDate AS DATE)
  FROM Payrolls pr
  INNER JOIN Users u
    ON pr.UserId = u.UserId
  INNER JOIN Cashiers c
    ON u.UserId = c.UserId
  WHERE u.UserId = @UserId
  AND CAST(PR.FromDate AS DATE) >= CAST('2024-01-07' AS DATE)--"Las LEAVE HOURS (PL) se empiezan a acumular desde el primer payroll pagado después de 07-01-2024".
  ORDER BY CAST(pr.ToDate AS DATE) DESC)
OR (@NoAccumulatePreviousCycles = 1))--When we are paying the payroll, we need only get the info to the end of the cicle
))


--Find the first date cycle
SET @FirstPayrollDate = (SELECT TOP 1
    pr.FromDate
  FROM Payrolls pr
  INNER JOIN Users u
    ON pr.UserId = u.UserId
  INNER JOIN Cashiers c
    ON u.UserId = c.UserId
  WHERE u.UserId = @UserId
  AND CAST(PR.FromDate AS DATE) >= CAST('2024-01-07' AS DATE) --"Las LEAVE HOURS (PL) se empiezan a acumular desde el primer payroll pagado después de 07-01-2024".
  ORDER BY pr.FromDate ASC)

-- Get the month and day of StartingDate
SET @MonthStarting = MONTH(@StartingDate);
SET @DayStarting = DAY(@StartingDate);

-- Get the month and day of FirstPayrollDate
SET @MonthFromPayroll = MONTH(@FirstPayrollDate);
SET @DayFromPayroll = DAY(@FirstPayrollDate);

---- Evaluar si la fecha de inicio(@StartingDate) ocurre antes o el mismo día (en mes/día) que la primera fecha de nómina
SET @IsStartBeforeOrEqualPayroll =
CASE
  WHEN @MonthStarting < @MonthFromPayroll THEN 1
  WHEN @MonthStarting = @MonthFromPayroll AND
    @DayStarting <= @DayFromPayroll THEN 1
  ELSE 0
END;

  -- Calcular el año del ciclo real actual
  DECLARE @CycleYear INT =
  CASE
    WHEN @IsStartBeforeOrEqualPayroll = 1 THEN YEAR(@FirstPayrollDate) --  	//If the month and day of the startingDate are less than or equal to the month and day of the first payroll payment(StartDatePayroll), then the year of the cycle should be the year of the first payroll payment plus the month and day of the startingDate.
    ELSE YEAR(@FirstPayrollDate) - 1  --If the month and day of the startingDate are greater than the first payroll payment(StartDatePayroll), then the year should be the year of the first payroll payment minus 1, plus the month and day of the startingDate.
  END;

--Set the FIRST cycle
SET @FirstCycleDate = datefromparts(@CycleYear, @MonthStarting, @DayStarting);


  --we need to know if the user has LeaveHoursAccumulated in previous cycles (this var is true, when we are pay the payroll, because there we don't need to get the accumulated hours 
  IF (@NoAccumulatePreviousCycles = 0
    OR @NoAccumulatePreviousCycles IS NULL)--@NoAccumulatePreviousCycles only arraive NULL when we are searching pending hors from paryoll, because in the payroll only need to get the current cycle
  BEGIN
SELECT
  @vacationHoursAccumulatedPreviousCycle = (SELECT
      ISNULL(SUM(Hours), 0)
    FROM EmployeeLeaveHoursAccumulated
    WHERE UserId = @UserId);
END

--Fourth We need to know the hours taken in the cycle
SELECT
  @hourstaken = ISNULL((SELECT
      ISNULL(SUM(Hours), 0)
    FROM EmployeeLeaveHours --Son las horas de vaciones que ha tomado
    WHERE UserId = @UserId
    AND (CAST(EmployeeLeaveHours.CycleDateLeaveHours AS DATE) >= @CycleDateLeaveHours
    AND CAST(EmployeeLeaveHours.CycleDateLeaveHours AS DATE) <= @CycleDateLeaveHours
    ))
  , 0)

--  IF (@CurrentCycleDateVacationTblUser IS NULL
--    OR (@FirstCycleDate >= @CurrentCycleDateVacationTblUser))
--  BEGIN
--    SELECT TOP 1
--      @vacationHoursAccumulated = (ISNULL(VacationHoursAccumulated, 0))
--    FROM Users
--    WHERE UserId = @UserId
--
--    SET @result =
--    CASE
--      WHEN (ISNULL(@hoursworked, 0) / 35) <= 40 THEN ((ISNULL(@hoursworked, 0) / 35) + @vacationHoursAccumulated) - @hourstaken
--      ELSE (40) - @hourstaken
--    END;
--  END
--  ELSE
--  BEGIN

SET @result =
CASE
  WHEN (ISNULL(@hoursworked, 0) / 35) <= 40 THEN ((ISNULL(@hoursworked, 0) / 35) + @vacationHoursAccumulatedPreviousCycle) - @hourstaken
  ELSE (40 + @vacationHoursAccumulatedPreviousCycle) - @hourstaken
--    END;
END


  --  SET @totalVacationHoursAccumulated = @vacationHoursAccumulated + @vacationHoursAccumulatedPreviousCycle;

  RETURN @result

END;
GO