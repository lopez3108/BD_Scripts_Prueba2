SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveInventoryElsAlert]
(
@InventoryELSId INT,
@Quantity INT
)
AS
     BEGIN
        

		UPDATE InventoryELS SET AlertQuantity = @Quantity
		WHERE InventoryELSId = @InventoryELSId


		SELECT @InventoryELSId




     END;
GO