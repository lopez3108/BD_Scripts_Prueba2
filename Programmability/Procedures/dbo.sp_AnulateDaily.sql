SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-03-17 JT/5739: Error con los missing y surplus + el cash admin en el report daily
--Este sp no se usa dentro del sistema, se usó en algún momento solo para recalcular unos dailys que estaban generando probelma con el missing
--No hay necesidad de pasarlo a otros ambientes puesto que el error ya fue resuelto direcmante en produccion
CREATE PROCEDURE [dbo].[sp_AnulateDaily] @Email VARCHAR = NULL,
@CreationDate DATE = NULL,
@DailyId INT = NULL,
@CashierId INT = NULL,
@AgencyId INT = NULL,
@AgencyCode VARCHAR = NULL

AS
BEGIN
  UPDATE Daily
  SET ClosedOnCashAdmin = NULL
     ,ClosedByCashAdmin = NULL
     , CashAdmin = 0
  FROM Daily D
  INNER JOIN Cashiers c
    ON D.CashierId = c.CashierId
  INNER JOIN Users u
    ON u.UserId = c.UserId
  INNER JOIN Agencies a
    ON D.AgencyId = a.AgencyId
  WHERE (U.[User] = @Email
  OR @Email IS NULL)
  AND (CAST(D.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
  OR @CreationDate IS NULL)
  AND (a.Code = @AgencyCode OR @AgencyCode is NULL)
--  UPDATE Daily
--  SET ClosedOnCashAdmin = NULL
--     ,ClosedByCashAdmin = NULL
--     ,CashAdmin = 0
--  FROM Daily D
--  INNER JOIN Cashiers c
--    ON D.CashierId = c.CashierId
--  INNER JOIN Users u
--    ON u.UserId = c.UserId
--  INNER JOIN Agencies a
--    ON D.AgencyId = a.AgencyId
--  WHERE
--  (CAST(D.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
--  OR @CreationDate IS NULL)
--  AND (a.AgencyId = @AgencyId OR @AgencyId is null)
--  AND (c.CashierId = @CashierId OR @CashierId is null)
END

GO