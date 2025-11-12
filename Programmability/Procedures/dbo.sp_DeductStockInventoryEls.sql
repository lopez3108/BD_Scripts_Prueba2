SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeductStockInventoryEls](@InventoryELSCode VARCHAR(10) ,@AgencyId INT, @CashierId INT = NULL)
AS
     BEGIN
	 DECLARE @InventoryELSByAgencyId INT;
         SET @InventoryELSByAgencyId =
         (
             SELECT TOP 1 InventoryELSByAgencyId
             FROM InventoryELS I
                  INNER JOIN InventoryELSByAgency IA ON I.InventoryELSId = IA.InventoryELSId
             WHERE I.Code = @InventoryELSCode AND IA.AgencyId = @AgencyId AND
			 (@CashierId IS NULL OR IA.CashierId = @CashierId)
         );
         UPDATE [dbo].[InventoryELSByAgency]
           SET
               InStock = InStock - 1
         WHERE InventoryELSByAgencyId = @InventoryELSByAgencyId;
     END;
GO