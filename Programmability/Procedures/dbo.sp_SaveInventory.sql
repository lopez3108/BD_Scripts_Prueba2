SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveInventory]
(@InventoryId   INT            = NULL,
 @Model         VARCHAR(30),
 @InStock       INT,
 @AgencyId      INT,
 @PurchaseValue DECIMAL(18, 2),
 @SellingValue  DECIMAL(18, 2),
 @IdSaved       INT OUTPUT
)
AS
     SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        BEGIN
            IF(@InventoryId IS NULL)
                BEGIN
                    INSERT INTO [dbo].[Inventory]
                    (Model,
                     PurchaseValue,
                     SellingValue
                    )
                    VALUES
                    (@Model,
                     @PurchaseValue,
                     @SellingValue
                    );
                    SET @IdSaved = @@IDENTITY;
                    SET @InventoryId = @@IDENTITY;
            END;
                ELSE
                BEGIN
                    UPDATE [dbo].[Inventory]
                      SET
                          Model = @Model,
                          PurchaseValue = @PurchaseValue,
                          SellingValue = @SellingValue
                    WHERE InventoryId = @InventoryId;
                    SET @IdSaved = @InventoryId;
            END;
            DECLARE @InventoryByAgencyId INT= NULL;
            SET @InventoryByAgencyId =
            (
                SELECT TOP 1 InventoryByAgencyId
                FROM InventoryByAgency
                WHERE(InventoryId = @InventoryId
                      OR @InventoryId = NULL)
                     AND AgencyId = @AgencyId
            );
            IF(@InventoryByAgencyId IS NULL)
                BEGIN
                    INSERT INTO [dbo].InventoryByAgency
                    (AgencyId,
                     InventoryId,
                     InStock
                    )
                    VALUES
                    (@AgencyId,
                     @InventoryId,
                     @InStock
                    );
                    SET @IdSaved = @@IDENTITY;
            END;
                ELSE
                BEGIN
                    UPDATE [dbo].InventoryByAgency
                      SET
                          InStock = @InStock
                    WHERE InventoryByAgencyId = @InventoryByAgencyId
                    SET @IdSaved = @InventoryByAgencyId
            END;
        END;
        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
    END CATCH;

GO