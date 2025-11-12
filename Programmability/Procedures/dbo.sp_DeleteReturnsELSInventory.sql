SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteReturnsELSInventory](@ReturnsELSId INT)
AS
    BEGIN
        DECLARE @currentStatus VARCHAR(3);
        SET @currentStatus =
        (
            SELECT TOP 1 ReturnELSStatus.Code
            FROM ReturnELSStatus
            WHERE ReturnsELSStatusId =
            (
                SELECT TOP 1 ReturnsELSStatusId
                FROM [dbo].[ReturnsELS]
                WHERE ReturnsELSId = @ReturnsELSId
            )
        );
        DECLARE @cashierId INT;
        SET @cashierId =
        (
            SELECT TOP 1 dbo.ReturnsELS.CashierId
            FROM dbo.ReturnsELS
            WHERE ReturnsELSId = @ReturnsELSId
        );

        -- Solo se pueden eliminar retornos en estado estado PENDING SHIPPING y  PENDING
        IF(@currentStatus = 'C01' or @currentStatus = 'C02' )
            BEGIN
                DECLARE @currentQuantity INT;
                SET @currentQuantity =
                (
                    SELECT TOP 1 Number
                    FROM ReturnsELS
                    WHERE ReturnsELSId = @ReturnsELSId
                );
                DECLARE @currentInvId INT;
                SET @currentInvId =
                (
                    SELECT TOP 1 InventoryELSId
                    FROM ReturnsELS
                    WHERE ReturnsELSId = @ReturnsELSId
                );
                DECLARE @currentAgency INT;
                SET @currentAgency =
                (
                    SELECT TOP 1 AgencyId
                    FROM ReturnsELS
                    WHERE ReturnsELSId = @ReturnsELSId
                );

                -- Devuelve los items al inventario
                UPDATE InventoryELSByAgency
                  SET 
                      InStock = InStock + @currentQuantity
                WHERE AgencyId = @currentAgency
                      AND InventoryELSId = @currentInvId
                      AND (@cashierId IS NULL
                           OR @cashierId = dbo.InventoryELSByAgency.CashierId);
                DELETE ReturnsELS
                WHERE ReturnsELSId = @ReturnsELSId;
                DELETE SerialsXReturn
                WHERE ReturnsELSId = @ReturnsELSId;
            END;
    END;
GO