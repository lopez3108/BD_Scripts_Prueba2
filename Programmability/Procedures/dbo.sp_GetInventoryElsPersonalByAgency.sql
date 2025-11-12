SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--CREATEDBY: JOHAN
--LASTUPDATED : 10-11-23
--CAMBIOS: SE INCLUYE CAJEROS QUE NO ESTAN EN LA AGENCIA Y UNA NUEVA VAIRIABLE @ISDISTRIBUTION, PARA IDETIFICAR QUE LISTA DEBE DE MOSRTRAR
CREATE PROCEDURE [dbo].[sp_GetInventoryElsPersonalByAgency] (@InventoryELSByAgencyId INT, @IsDistribution BIT)
AS
BEGIN


  DECLARE @agencyId INT
  SET @agencyId = (SELECT TOP 1
      AgencyId
    FROM dbo.InventoryELSByAgency
    WHERE InventoryELSByAgencyId = @InventoryELSByAgencyId)

  DECLARE @inventoryELSId INT
  SET @inventoryELSId = (SELECT TOP 1
      InventoryELSId
    FROM dbo.InventoryELSByAgency
    WHERE InventoryELSByAgencyId = @InventoryELSByAgencyId)

  BEGIN


    IF (@IsDistribution = 0)
    BEGIN
      SELECT DISTINCT
        *
      FROM (
        -- cajeros por agencia con inventario.
        SELECT
          ISNULL((SELECT TOP 1
              InStock
            FROM dbo.InventoryELSByAgency ia
            WHERE ia.AgencyId = @agencyId
            AND ia.CashierId = dbo.Cashiers.CashierId
            AND ia.InventoryELSId = @inventoryELSId)
          , 0) AS InStock
         ,dbo.Cashiers.CashierId
         ,dbo.Users.Name
         ,dbo.AgenciesxUser.UserId
         ,@InventoryELSByAgencyId AS InventoryELSByAgencyId
         ,@agencyId AS AgencyId
         ,@inventoryELSId AS InventoryELSId
         ,0 AS AddUnits
         ,(SELECT TOP 1
              AlertQuantity
            FROM InventoryELS
            WHERE InventoryELSId = @inventoryELSId)
          AS AlertQuantity
         ,CAST(0 AS BIT) IsNotInAgency
          
        FROM dbo.AgenciesxUser
        INNER JOIN dbo.Users
          ON dbo.AgenciesxUser.UserId = dbo.Users.UserId
        INNER JOIN dbo.Cashiers
          ON dbo.Users.UserId = dbo.Cashiers.UserId
        WHERE dbo.AgenciesxUser.AgencyId = @agencyId
        AND dbo.Cashiers.IsActive = 1


        UNION ALL
        -- cajeros que no estan en la agencia pero si tienen inventario en ella.
        SELECT
          InStock
         ,c.CashierId
         ,u.Name
         ,u.UserId
         ,@InventoryELSByAgencyId AS InventoryELSByAgencyId
         ,@agencyId AS AgencyId
         ,@inventoryELSId AS InventoryELSId
         ,0 AS AddUnits
         ,(SELECT TOP 1
              AlertQuantity
            FROM InventoryELS
            WHERE InventoryELSId = @inventoryELSId)
          AS AlertQuantity
          --     ,CASE
          --        WHEN NOT EXISTS (SELECT TOP 1
          --              *
          --            FROM AgenciesxUser au
          --            WHERE au.UserId = u.UserId
          --            AND au.AgencyId = @agencyId) THEN CAST(1 AS BIT)
          --        ELSE CAST(0 AS BIT)
          --      END AS IsNotInAgency
         ,CAST(1 AS BIT) IsNotInAgency
        FROM InventoryELSByAgency I
        INNER JOIN Cashiers c
          ON I.CashierId = c.CashierId
        INNER JOIN Users u
          ON u.UserId = c.UserId
        WHERE I.AgencyId = @agencyId
        AND c.IsActive = 1
        AND I.InStock > 0
        AND I.InventoryELSId = @inventoryELSId
        AND NOT EXISTS (SELECT
            au.UserId
          FROM AgenciesxUser au
          WHERE au.UserId = u.UserId
          AND au.AgencyId = I.AgencyId)) AS QUERY
      ORDER BY QUERY.InStock, QUERY.Name

    END
    ELSE -- Cuando se hace la distrubucion de inventario
    BEGIN
      SELECT
        ISNULL((SELECT TOP 1
            InStock
          FROM dbo.InventoryELSByAgency ia
          WHERE ia.AgencyId = @agencyId
          AND ia.CashierId = dbo.Cashiers.CashierId
          AND ia.InventoryELSId = @inventoryELSId)
        , 0) AS InStock
       ,dbo.Cashiers.CashierId
       ,dbo.Users.Name
       ,dbo.AgenciesxUser.UserId
       ,@InventoryELSByAgencyId AS InventoryELSByAgencyId
       ,@agencyId AS AgencyId
       ,@inventoryELSId AS InventoryELSId
       ,0 AS AddUnits
       ,(SELECT TOP 1
            AlertQuantity
          FROM InventoryELS
          WHERE InventoryELSId = @inventoryELSId)
        AS AlertQuantity
       ,CAST(0 AS BIT) IsNotInAgency
          
      FROM dbo.AgenciesxUser
      INNER JOIN dbo.Users
        ON dbo.AgenciesxUser.UserId = dbo.Users.UserId
      INNER JOIN dbo.Cashiers
        ON dbo.Users.UserId = dbo.Cashiers.UserId
      WHERE dbo.AgenciesxUser.AgencyId = @agencyId
      AND dbo.Cashiers.IsActive = 1
      ORDER BY InStock, Name
    END
  END




END;


GO