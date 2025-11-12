SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--CREATE BY JOHAN MARIN
--LAST UPDATED ON 22-11-2023
--USO 5456 TRAE NUMERO DE MISSING SIN PAGOS
CREATE PROCEDURE [dbo].[sp_GetNumberDailysWithMissingNotPaid] (@UserId INT ,
@AgencyId INT)
AS

BEGIN
  SELECT
    COUNT(*) AS NumberMissing
  FROM Daily D
  INNER JOIN Cashiers c
    ON D.CashierId = c.CashierId
  INNER JOIN Users u
    ON c.UserId = u.UserId
  WHERE D.AgencyId = @AgencyId
  AND u.UserId = @UserId
  AND ABS(D.Missing) > 0
  AND D.Surplus = 0
END
GO