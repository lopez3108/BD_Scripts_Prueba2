SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveInventoryEls]
(@InventoryELSId INT      = NULL, 
 @OrderDate      DATETIME, 
 @Units          INT, 
 @UserId         INT, 
 @AgencyId       INT
 
)
AS
    BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @InventoryELSByAgencyId INT= NULL;
        SET @InventoryELSByAgencyId =
        (
            SELECT TOP 1 InventoryELSByAgencyId
            FROM InventoryELSByAgency
            WHERE(InventoryELSId = @InventoryELSId
                  OR @InventoryELSId = NULL)
                 AND AgencyId = @AgencyId
        );
        IF(@InventoryELSByAgencyId IS NULL)
            BEGIN
                INSERT INTO [dbo].[InventoryELSByAgency]
                (AgencyId,
                 InventoryELSId,
                 InStock
                )
                VALUES
                (@AgencyId,
                 @InventoryELSId,
                 @Units
                );
                SET @InventoryELSByAgencyId = @@IDENTITY;
        END;
            ELSE
            BEGIN
                UPDATE [dbo].[InventoryELSByAgency]
                  SET
                      InStock = InStock + @Units
                WHERE InventoryELSId = @InventoryELSId
                      AND AgencyId = @AgencyId;

					  DECLARE @sentStatus INT
					  SET @sentStatus = (SELECT TOP 1 InventoryELSOrdersStatusId FROM InventoryELSOrdersStatus WHERE Code = 'C03')

					    DECLARE @closedStatus INT
					  SET @closedStatus = (SELECT TOP 1 InventoryELSOrdersStatusId FROM InventoryELSOrdersStatus WHERE Code = 'C02')

					  UPDATE dbo.InventoryELSOrders
					  SET
					  ClosedBy = @UserId,
					  ClosedDate = @OrderDate,
					  ClosedUnits = @Units,
					  InventoryELSOrdersStatusId = @closedStatus
					  WHERE 
					  InventoryELSOrdersStatusId = @sentStatus AND
					  InventoryELSByAgencyId = (SELECT TOP 1 InventoryELSByAgencyId FROM InventoryELSByAgency WHERE AgencyId = @AgencyId AND InventoryELSId = @InventoryELSId)


        END;
        
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
    END CATCH;
GO