SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetImeisByInventoryId] @InventoryByAgencyId INT
AS
     BEGIN
         SELECT [ImeiId],
                [Imei],
                [InventoryByAgencyId]
         FROM [dbo].[Imei]
         WHERE InventoryByAgencyId = @InventoryByAgencyId;
     END;


GO