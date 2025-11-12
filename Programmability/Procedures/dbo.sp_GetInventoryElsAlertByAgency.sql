SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetInventoryElsAlertByAgency] (@AgencyId INT)
AS
BEGIN

  -- Crea inventarios por agencia en caso de no existir
  EXEC [dbo].[sp_SaveInventoryElsInAgency] @AgencyId;
  SELECT
    dbo.InventoryELSByAgency.InventoryELSByAgencyId
   ,dbo.InventoryELSByAgency.AgencyId
   ,dbo.InventoryELSByAgency.InventoryELSId
   ,dbo.InventoryELSByAgency.InStock
   ,dbo.InventoryELS.AlertQuantity
   ,dbo.InventoryELS.Description
   ,dbo.InventoryELS.InventoryFormRequired
   ,CASE
      WHEN InventoryFormFileName IS NOT NULL THEN CAST(1 AS BIT)
      ELSE CAST(0 AS BIT)
    END AS HasForm
   ,dbo.InventoryELS.Code
  FROM dbo.InventoryELSByAgency
  RIGHT JOIN dbo.InventoryELS
    ON dbo.InventoryELSByAgency.InventoryELSId = dbo.InventoryELS.InventoryELSId
  WHERE dbo.InventoryELSByAgency.AgencyId = @AgencyId
  AND dbo.InventoryELS.IsPersonalInventory = 0
  AND dbo.InventoryELS.AlertActive = 1
  AND dbo.InventoryELSByAgency.InStock <= dbo.InventoryELS.AlertQuantity
  AND dbo.InventoryELS.InventoryELSId NOT IN (SELECT
      ia.InventoryELSId
    FROM dbo.InventoryELSOrders i
    INNER JOIN dbo.InventoryELSByAgency ia
      ON i.InventoryELSByAgencyId = ia.InventoryELSByAgencyId
    WHERE ia.AgencyId = @AgencyId
    AND i.InventoryELSOrdersStatusId NOT IN (SELECT
        InventoryELSOrdersStatusId
      FROM InventoryELSOrdersStatus
      WHERE Code IN ('C02')))
  AND dbo.InventoryELS.Code NOT IN ('TRP1', 'TRP2')
  UNION
  SELECT
    *
  FROM (SELECT
      (SELECT TOP 1
          InventoryELSByAgencyId
        FROM dbo.InventoryELSByAgency iag
        WHERE iag.AgencyId = @AgencyId
        AND iag.InventoryELSId = I.InventoryELSId)
      AS InventoryELSByAgencyId
     ,@AgencyId AS AgencyId
     ,I.InventoryELSId
     ,(SELECT TOP 1
          ISNULL(InStock, 0) AS InStock
        FROM dbo.AgenciesxUser
        INNER JOIN dbo.Users
          ON dbo.AgenciesxUser.UserId = dbo.Users.UserId
        INNER JOIN dbo.Cashiers
          ON dbo.Users.UserId = dbo.Cashiers.UserId
        LEFT OUTER JOIN dbo.InventoryELSByAgency
          ON dbo.Cashiers.CashierId = dbo.InventoryELSByAgency.CashierId
          AND dbo.InventoryELSByAgency.AgencyId = @AgencyId
          AND dbo.InventoryELSByAgency.InventoryELSId = I.InventoryELSId
        WHERE dbo.AgenciesxUser.AgencyId = @AgencyId
        AND dbo.Cashiers.IsActive = 1
        ORDER BY InStock ASC)
      AS InStock
     ,I.AlertQuantity
     ,I.Description
     ,I.InventoryFormRequired
     ,CASE
        WHEN InventoryFormFileName IS NOT NULL THEN CAST(1 AS BIT)
        ELSE CAST(0 AS BIT)
      END AS HasForm
     ,I.Code
    FROM dbo.InventoryELS I
    LEFT OUTER JOIN dbo.InventoryELSByAgency IA
      ON IA.InventoryELSId = I.InventoryELSId
    WHERE IsPersonalInventory = 1 AND I.AlertActive = 1 ) t
  WHERE t.InStock <= AlertQuantity
  AND t.InventoryELSId NOT IN (SELECT
      ia.InventoryELSId
    FROM dbo.InventoryELSOrders i
    INNER JOIN dbo.InventoryELSByAgency ia
      ON i.InventoryELSByAgencyId = ia.InventoryELSByAgencyId
    WHERE ia.AgencyId = @AgencyId
    AND i.InventoryELSOrdersStatusId NOT IN (SELECT
        InventoryELSOrdersStatusId
      FROM InventoryELSOrdersStatus
      WHERE Code IN ('C02')))
  UNION
  SELECT
    0 InventoryELSByAgencyId
   ,dbo.InventoryELSByAgency.AgencyId
   ,0 InventoryELSId
   ,SUM(ISNULL(dbo.InventoryELSByAgency.InStock, 0)) AS InStock
   ,dbo.InventoryELS.AlertQuantity
   ,'TRP (7-30 DAYS)' AS Description
   ,NULL
   ,NULL
   ,dbo.InventoryELS.Code
  FROM dbo.InventoryELSByAgency
  RIGHT JOIN dbo.InventoryELS
    ON dbo.InventoryELSByAgency.InventoryELSId = dbo.InventoryELS.InventoryELSId
  WHERE dbo.InventoryELSByAgency.AgencyId = @AgencyId AND dbo.InventoryELS.AlertActive = 1
  --AND dbo.InventoryELSByAgency.InStock <= dbo.InventoryELS.AlertQuantity
  AND dbo.InventoryELS.InventoryELSId NOT IN (SELECT
      a.InventoryELSId
    FROM InventoryELSAlerts a
    WHERE AgencyId = @AgencyId
    AND a.InventoryELSId = dbo.InventoryELS.InventoryELSId
    AND a.ClosedDate IS NULL)
  AND dbo.InventoryELS.Code IN ('TRP1', 'TRP2')
  GROUP BY dbo.InventoryELSByAgency.AgencyId
          ,dbo.InventoryELS.AlertQuantity
          ,dbo.InventoryELS.Code
  HAVING (SUM(dbo.InventoryELSByAgency.InStock) <= dbo.InventoryELS.AlertQuantity);
END;
GO