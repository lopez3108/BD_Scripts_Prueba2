SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-08-29 JT/6225: Fix error taken hours 

CREATE PROCEDURE [dbo].[sp_GetNumberPendingsVacationsCashier] (@CurrentDate DATETIME,
@UserId INT)
AS
BEGIN
  SELECT


    ISNULL((SELECT
        [dbo].[CalculateVacations](@UserId, C.CycleDateVacation, NULL))
    , 0) AS hoursCashier
  FROM dbo.Users u
  INNER JOIN Cashiers C
    ON C.UserId = u.UserId
  WHERE (u.UserId = @UserId)
  AND ((CAST(@CurrentDate AS DATE) > CAST(C.CycleDateVacation AS DATE)))
-- Commented in task -- 2024-08-29 JT/6225: Fix error taken hours 
--No se encontró ningún sentido a esta validacón, por lo tanto se comenta ya que era lo que estaba haciendo que no se pudieran tomar las horas 
--  AND NOT EXISTS (SELECT
--      pr.PayrollId
--    FROM Payrolls pr
--    WHERE pr.VacationHours > 0
--    AND (((CAST(pr.PaidOn AS DATE) >= CAST(DATEADD(YEAR, -1, C.CycleDateVacation) AS DATE)))
--    AND ((CAST(pr.PaidOn AS DATE) <= CAST(C.CycleDateVacation AS DATE)))));
END;





GO