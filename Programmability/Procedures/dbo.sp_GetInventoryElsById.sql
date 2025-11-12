SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetInventoryElsById](@InventoryELSId INT)
AS
     BEGIN
         SELECT p.InventoryELSId,
                p.Code,
                p.Description
                --p.InStock
         FROM InventoryELS p
         WHERE InventoryELSId = @InventoryELSId;
     END;
GO