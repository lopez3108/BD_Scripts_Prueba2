SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--CREATEDBY: JOHAN
--CREATEDON: 3-11-23
--USO: VERIFICA INVENTARIO DEL CAJERO A INACTIVAR
CREATE PROCEDURE [dbo].[sp_VerifyUserInventoryInAgenciesByUserId] (@UserId INT)
AS

BEGIN
  IF EXISTS (SELECT TOP 1
        iea.InStock
      FROM InventoryELSByAgency iea
      INNER JOIN Cashiers c
        ON iea.CashierId = c.CashierId
      INNER JOIN Users u
        ON u.UserId = c.UserId
      WHERE u.UserId = @UserId)
  BEGIN
    SELECT
      t.InStock
     ,ie.Description
     ,t.AgencyId
     ,a.Code + ' - ' + a.Name AS Agency
    FROM InventoryELSByAgency t
    INNER JOIN InventoryELS ie
      ON t.InventoryELSId = ie.InventoryELSId
    INNER JOIN Agencies a
      ON t.AgencyId = a.AgencyId
    INNER JOIN Cashiers c
      ON t.CashierId = c.CashierId
    INNER JOIN Users u
      ON u.UserId = c.UserId
    WHERE u.UserId = @UserId AND  t.InStock > 0 AND ie.IsPersonalInventory = 1

  END


END;



GO