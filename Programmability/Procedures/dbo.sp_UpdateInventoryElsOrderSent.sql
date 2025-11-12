SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_UpdateInventoryElsOrderSent]
(@InventoryELSOrderId INT,
 @SentBy INT = NULL,
 @SentDate DATETIME = NULL,
 @InventoryFormFileName VARCHAR(100) = NULL


)
AS
BEGIN


		 DECLARE @sentStatusId INT
		 SET @sentStatusId = (SELECT TOP 1 InventoryELSOrdersStatusId FROM InventoryELSOrdersStatus WHERE Code = 'C03') 

UPDATE [dbo].[InventoryELSOrders]
   SET 
      [SentBy] = @SentBy
      ,[SentDate] = @SentDate
      ,[InventoryFormFileName] = @InventoryFormFileName
	  ,[InventoryELSOrdersStatusId] = @sentStatusId
 WHERE InventoryELSOrderId = @InventoryELSOrderId


 SELECT @InventoryELSOrderId



     END;
GO