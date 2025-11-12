SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveImei]
(@ImeiId      INT        = NULL,
 @Imei        VARCHAR(4),
 @InventoryByAgencyId INT
)
AS
     BEGIN
         IF(@ImeiId IS NULL)
             BEGIN
                 IF NOT EXISTS
                 (
                     SELECT Imei
                     FROM Imei
                     WHERE Imei = @Imei
                           AND InventoryByAgencyId = @InventoryByAgencyId
                 )
                     BEGIN
                         INSERT INTO [dbo].[Imei]
                         (Imei,
                          InventoryByAgencyId
                         )
                         VALUES
                         (@Imei,
                          @InventoryByAgencyId
                         );
                 END;
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].[Imei]
                   SET
                       Imei = @Imei,
                       InventoryByAgencyId = @InventoryByAgencyId
                 WHERE ImeiId = @ImeiId;
         END;
     END;

GO