SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetDiscountPhoneAgencyByDateByPhoneSaleId]
(@PhoneSaleId     INT,
 @DiscountPhoneId INT  = NULL,
 @AgencyId        INT,
 @CreationDate    DATE
)
AS
     BEGIN
         SELECT i.Model+' - '+p.Imei AS ModelImei
         FROM DiscountPhones d
              INNER JOIN [dbo].PhoneSales p ON d.PhoneSaleId = p.PhoneSalesId
              INNER JOIN [InventoryByAgency] ia ON p.InventoryByAgencyId = ia.InventoryByAgencyId
              INNER JOIN Inventory i ON i.InventoryId = ia.InventoryId
         WHERE(CAST(d.CreationDate AS DATE) = CAST(@CreationDate AS DATE))
              AND d.AgencyId = @AgencyId
              AND d.PhoneSaleId = @PhoneSaleId
              AND (d.DiscountPhoneId <> @DiscountPhoneId
                   OR @DiscountPhoneId IS NULL);
     END;
GO