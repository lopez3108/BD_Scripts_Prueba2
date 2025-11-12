SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveInventoryOrders]
(@InventoryOrderId INT            = NULL,
 @OrderDate        DATETIME,
 @InventoryByAgencyId      INT,
 @Units            INT,
 @PurchaseValue    DECIMAL(18, 2),
 @SellingValue     DECIMAL(18, 2),
 @OrderedBy        INT
)
AS
     BEGIN
         IF(@InventoryOrderId IS NULL)
             BEGIN
                 INSERT INTO [dbo].[InventoryOrders]
                 (OrderDate,
                  InventoryByAgencyId,
                  Units,
                  PurchaseValue,
                  SellingValue,
                  OrderedBy
                 )
                 VALUES
                 (@OrderDate,
                  @InventoryByAgencyId,
                  @Units,
                  @PurchaseValue,
                  @SellingValue,
                  @OrderedBy
                 );
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].[InventoryOrders]
                   SET
                       OrderDate = @OrderDate,
                       InventoryByAgencyId = @InventoryByAgencyId,
                       Units = @Units,
                       PurchaseValue = @PurchaseValue,
                       SellingValue = @SellingValue,
                       OrderedBy = @OrderedBy
                 WHERE InventoryOrderId = @InventoryOrderId
         END;
     END;

GO