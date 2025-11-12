SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllInventoryElsByAgency] (@InventoryELSId INT = NULL,
@AgencyId INT)
AS
BEGIN
  SELECT
  I.InventoryELSId,
    a.Name AS AgencyName
   ,ISNULL(IA.InStock, 0) AS InStock
   ,I.Description AS Description
   ,a.Code + ' - ' + a.Name AS AgencyCodeName
   ,I.Code
   ,IA.InventoryELSByAgencyId
   ,I.IsPersonalInventory
   ,I.InventoryFormFileName
   ,I.InventoryFormRequired
   ,CASE
      WHEN I.InventoryFormFileName IS NULL THEN CAST(0 AS BIT)
      ELSE CAST(1 AS BIT)
    END AS HasForm
  FROM InventoryELS I
  LEFT JOIN InventoryELSByAgency IA
    ON I.InventoryELSId = IA.InventoryELSId
      AND IA.AgencyId = @AgencyId
  LEFT JOIN Agencies a
    ON IA.AgencyId = a.AgencyId
  WHERE (@InventoryELSId IS NULL
  OR IA.InventoryELSId = @InventoryELSId)
  AND I.IsPersonalInventory = 0
  UNION
  SELECT
  InventoryELSId,
    a.Name AS AgencyName
   ,ISNULL((SELECT
        SUM(InStock)
      FROM dbo.InventoryELSByAgency ia
      INNER JOIN Cashiers c ON c.CashierId = ia.cashierId
      WHERE ia.AgencyId = @AgencyId
      AND ia.InventoryELSId = I.InventoryELSId AND c.IsActive = 1)
    , 0) AS InStock
   ,I.Description AS Description
   ,a.Code + ' - ' + a.Name AS AgencyCodeName
   ,I.Code
   ,(SELECT TOP 1
        ia.InventoryELSByAgencyId
      FROM dbo.InventoryELSByAgency ia
      WHERE ia.AgencyId = @AgencyId
      AND ia.InventoryELSId = I.InventoryELSId)
    AS InventoryELSByAgencyId
   ,I.IsPersonalInventory
   ,I.InventoryFormFileName
   ,I.InventoryFormRequired
   ,CASE
      WHEN I.InventoryFormFileName IS NULL THEN CAST(0 AS BIT)
      ELSE CAST(1 AS BIT)
    END AS HasForm
  FROM InventoryELS I
  JOIN dbo.Agencies a
    ON a.AgencyId = @AgencyId
  WHERE I.IsPersonalInventory = 1  


END
GO