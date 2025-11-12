SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllInventoryByAgency]
(@Model    VARCHAR(30) = NULL,
 @AgencyId INT
)
AS
     BEGIN
         SELECT   a.Code+' - '+a.Name AS AgencyName , *
         FROM Inventory i
              INNER JOIN InventoryByAgency ia ON i.InventoryId = ia.InventoryId
		      INNER JOIN Agencies a ON ia.AgencyId = a.AgencyId
         WHERE (Model LIKE '%'+@Model+'%'
               OR @Model IS NULL)
               AND ia.AgencyId = @AgencyId and InStock > 0;
     END;
GO