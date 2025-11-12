SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllInventoryByModelCoincidences](@Model VARCHAR(30))
AS
     BEGIN
         SELECT *
         FROM Inventory p
              LEFT JOIN InventoryByAgency ia ON p.InventoryId = ia.InventoryId
         WHERE REPLACE(p.Model, ' ', '') = REPLACE(@Model, ' ', '');
     END;


GO