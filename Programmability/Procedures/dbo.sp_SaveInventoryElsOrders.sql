SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveInventoryElsOrders]
(@InventoryELSOrderId INT          = NULL,
 @InventoryELSByAgencyId      INT,
 @OrderedBy           INT,
 @OrderDate         DATETIME,
 @Units               INT,
 @SentBy INT = NULL,
 @SentDate DATETIME = NULL,
 @ClosedDate DATETIME = NULL,
 @ClosedBy INT = NULL,
  @ClosedUnits INT = NULL

)
AS
     IF(@InventoryELSOrderId IS NULL)
         BEGIN

		 DECLARE @openStatusId INT
		 SET @openStatusId = (SELECT TOP 1 InventoryELSOrdersStatusId FROM InventoryELSOrdersStatus WHERE Code = 'C01')

		 DECLARE @sentStatusId INT
		 SET @sentStatusId = (SELECT TOP 1 InventoryELSOrdersStatusId FROM InventoryELSOrdersStatus WHERE Code = 'C03')


		 DECLARE @invId INT
		 SET @invId = (SELECT TOP 1 InventoryELSId FROM InventoryELSByAgency WHERE InventoryELSByAgencyId = @InventoryELSByAgencyId)

		 DECLARE @invHasForm BIT
		 SET @invHasForm = (SELECT TOP 1 
		  CASE
			   WHEN InventoryFormFileName IS NOT NULL THEN
			   CAST(1 as BIT)
			   ELSE
			   CAST(1 as BIT)
			   END as HasForm
		 FROM InventoryELS WHERE InventoryELSId = @invId)

		  DECLARE @invFormRequired BIT
		 SET @invFormRequired = (SELECT TOP 1 
		  InventoryFormRequired
		 FROM InventoryELS WHERE InventoryELSId = @invId)

		 DECLARE @finalStatus INT
		 SET @finalStatus = @openStatusId

		 IF(@invHasForm = 0 OR @invFormRequired = 0)
		 BEGIN

		 SET @finalStatus = @sentStatusId

		 SET @SentBy = @OrderedBy

		 SET @SentDate = @OrderDate

		 END


             INSERT INTO [dbo].[InventoryELSOrders]
             (OrderedBy,
             -- InventoryELSId,
              OrderDate,
              Units,
			  InventoryELSOrdersStatusId,
			  InventoryELSByAgencyId,
			   SentBy,
			   SentDate,
			   ClosedBy,
			   ClosedDate,
			   ClosedUnits
             )
             VALUES
             (--@InventoryELSId,
              @OrderedBy,
              @OrderDate,
              @Units,
			  @finalStatus,
			  @InventoryELSByAgencyId,
			   @SentBy ,
 @SentDate ,
  @ClosedBy,
 @ClosedDate,
  @ClosedUnits 
             );

			 SELECT @@IDENTITY
     END;
         ELSE
         BEGIN
             UPDATE [dbo].[InventoryELSOrders]
               SET
                   Units = @Units
             WHERE InventoryELSOrderId = @InventoryELSOrderId;

			 SELECT @InventoryELSOrderId
     END;
GO