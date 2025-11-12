SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteInventoryEls](@InventoryELSId INT)
AS
     BEGIN
         DELETE InventoryELS
         WHERE InventoryELSId = @InventoryELSId;
         SELECT 1;
     END;


GO