SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetInventoryByModel](@Model VARCHAR(30) , @AgencyId INT)
AS
     BEGIN
         SELECT TOP 1  *
         FROM Inventory P LEFT JOIN InventoryByAgency IA ON P.InventoryId = IA.InventoryId AND 
	    IA.AgencyId = @AgencyId
         WHERE p.Model = @Model;
     END;


GO