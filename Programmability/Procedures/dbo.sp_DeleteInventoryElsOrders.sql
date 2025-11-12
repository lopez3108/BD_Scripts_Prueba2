SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteInventoryElsOrders]
(@InventoryELSOrderId INT  
)
AS
BEGIN

declare @currentStatus VARCHAR(3)
SET @currentStatus = (SELECT TOP 1 dbo.InventoryELSOrdersStatus.Code
FROM     dbo.InventoryELSOrdersStatus INNER JOIN
                  dbo.InventoryELSOrders ON dbo.InventoryELSOrdersStatus.InventoryELSOrdersStatusId = dbo.InventoryELSOrders.InventoryELSOrdersStatusId
				  WHERE dbo.InventoryELSOrders.InventoryELSOrderId = @InventoryELSOrderId)

IF(@currentStatus = 'C01')
BEGIN

DELETE dbo.InventoryELSOrders WHERE dbo.InventoryELSOrders.InventoryELSOrderId = @InventoryELSOrderId 


END




     END;
GO