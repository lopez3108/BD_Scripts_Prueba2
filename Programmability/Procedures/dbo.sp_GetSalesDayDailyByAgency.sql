SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetSalesDayDailyByAgency]
(@Creationdate DATE,
 @AgencyId     INT
)
AS
     BEGIN
         SELECT p.PhoneSalesId,
                p.PurchaseValue,
                p.SellingValue,
                p.CreationDate,
                p.CreatedBy,
                p.Imei,
                p.PhonePlanId,
                p.InventoryByAgencyId,
                i.Model+ ' - ' +p.Imei AS ModelImei,
			 p.CardPayment,
			 p.CardPaymentFee,
			  p.LastUpdatedOn,
         usu.Name LastUpdatedByName
         FROM [dbo].PhoneSales p
		 LEFT JOIN Users usu ON p.LastUpdatedBy = usu.UserId
              INNER JOIN [InventoryByAgency] ia ON p.InventoryByAgencyId = ia.InventoryByAgencyId
              INNER JOIN Inventory i ON i.InventoryId = ia.InventoryId
         WHERE(CAST(CreationDate AS DATE) = CAST(@CreationDate AS DATE)
               OR @CreationDate IS NULL)
              AND AgencyId = @AgencyId;
     END;
GO