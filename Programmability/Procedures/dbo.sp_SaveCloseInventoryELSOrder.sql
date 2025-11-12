SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveCloseInventoryELSOrder]
(
@InventoryELSId INT,
@UserId INT,
@ClosedDate DATETIME,
@Units INT,
@AgencyId INT
)
AS
     BEGIN


	   DECLARE @sentStatus INT
					  SET @sentStatus = (SELECT TOP 1 InventoryELSOrdersStatusId FROM InventoryELSOrdersStatus WHERE Code = 'C03')

					    DECLARE @closedStatus INT
					  SET @closedStatus = (SELECT TOP 1 InventoryELSOrdersStatusId FROM InventoryELSOrdersStatus WHERE Code = 'C02')

					  UPDATE dbo.InventoryELSOrders
					  SET
					  ClosedBy = @UserId,
					  ClosedDate = @ClosedDate,
					  ClosedUnits = @Units,
					  InventoryELSOrdersStatusId = @closedStatus
					  WHERE 
					  InventoryELSOrdersStatusId = @sentStatus AND
					  InventoryELSByAgencyId IN (SELECT InventoryELSByAgencyId FROM InventoryELSByAgency WHERE AgencyId = @AgencyId AND InventoryELSId = @InventoryELSId)

     END;
GO