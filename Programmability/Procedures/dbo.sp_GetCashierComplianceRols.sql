SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetCashierComplianceRols] @userId INT

AS
BEGIN
  SELECT
    rc.RolName,
    rc.Code
 FROM RolCompliance rc
  INNER JOIN Cashiers c
    ON c.ComplianceRol = rc.RolComplianceId
  WHERE c.UserId = @userId
END
GO