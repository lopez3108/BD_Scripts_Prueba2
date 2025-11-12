SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Last update by jt/14-08-2024 task 6003 -Sin importar que hayan SICK HOURS (AVAILABLE) el sistema ya no debe de mostrar en la alerta los cajeros inactivos (la regulación dice que si un cajero renuncia o es despedido y tiene SICK HOURS (AVAILABLE) no es responsabilidad del empleador pagarlas)
--Last update by jt/25-07-2024 task 5878 Change logic of calculate sick hours
--returns the calculation of pending unpaid vacation hours
CREATE PROCEDURE [dbo].[sp_GetNumberPendingsVacations] (@CurrentDate DATETIME, @UserId INT = NULL)
AS
BEGIN
  DECLARE @ListAgencyId AS NCHAR(1000);

  IF (@UserId IS NOT NULL)--When @userid is not null, means that the information is require by manager, and we need to filter in whole agencies
  BEGIN
    SET @ListAgencyId = (SELECT
        STRING_AGG(AgencyId, ',')
      FROM AgenciesxUser aus
      WHERE aus.UserId = @UserId);

    SELECT
      COUNT(*) Pendings
    FROM dbo.Users u
    INNER JOIN Cashiers C
    LEFT JOIN AgenciesxUser au
      ON C.UserId = au.UserId
    LEFT JOIN Agencies a
      ON au.AgencyId = a.AgencyId
      ON C.UserId = u.UserId
        AND C.IsActive = 1
        AND (a.AgencyId IN (SELECT
              item
            FROM dbo.FN_ListToTableInt(@ListAgencyId))
          OR @ListAgencyId IS NULL)
    WHERE ((SELECT
        [dbo].[CalculateVacations](u.UserId, C.CycleDateVacation, NULL))
    > 0)
    AND EXISTS (SELECT --The vacation hours Only apply when the cashier has a previus payroll
        pr.PayrollId
      FROM Payrolls pr
      INNER JOIN Users u
        ON pr.UserId = u.UserId
      INNER JOIN Cashiers c
        ON u.UserId = c.UserId
      WHERE u.UserId = u.UserId)
  END
  ELSE--When @userid is null, means that the information is require by admin
  BEGIN
    SELECT
      COUNT(*) Pendings
    FROM dbo.Users u
    INNER JOIN Cashiers C
      ON u.UserId = C.UserId
    WHERE ((SELECT
        [dbo].[CalculateVacations](u.UserId, C.CycleDateVacation, NULL))
    > 0)
    AND C.IsActive = 1
    AND EXISTS (SELECT --The vacation hours Only apply when the cashier has a previus payroll
        pr.PayrollId
      FROM Payrolls pr
      INNER JOIN Users u
        ON pr.UserId = u.UserId
      INNER JOIN Cashiers c
        ON u.UserId = c.UserId
      WHERE u.UserId = u.UserId)
  END

END









GO