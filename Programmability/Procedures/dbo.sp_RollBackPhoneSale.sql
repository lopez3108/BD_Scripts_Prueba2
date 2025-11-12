SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_RollBackPhoneSale] @PhoneSalesId        INT,
                                             @InventoryByAgencyId INT,
                                             @Imei                VARCHAR(10)
AS
     BEGIN
	--CREATE IMEI
         INSERT INTO [dbo].[Imei]
         ([InventoryByAgencyId],
          [Imei]
         )
         VALUES
         (@InventoryByAgencyId,
          @Imei
         );                

	 -- Updates the inventory
         UPDATE [dbo].[InventoryByAgency]
           SET
               [InStock] = [InStock] + 1
         WHERE InventoryByAgencyId = @InventoryByAgencyId;

 -- Deletes the phone sale
         DELETE FROM [dbo].[PhoneSales]
         WHERE PhoneSalesId = @PhoneSalesId;
     END;
GO