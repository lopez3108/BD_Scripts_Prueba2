SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetPhoneSales] @InventoryId  INT  = NULL,
                                         @CreationDate DATE = NULL,
                                         @AgencyId     INT
AS
     BEGIN
         SELECT dbo.PhoneSales.PhoneSalesId,
                i.InventoryId,
                i.PurchaseValue,
                dbo.PhoneSales.SellingValue,
                dbo.PhoneSales.CreationDate,
				FORMAT(PhoneSales.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  CreationDateFormat,
                dbo.PhoneSales.CreatedBy,
                dbo.PhoneSales.Imei,
                i.Model,
                dbo.Users.Name,
                a.Code+' - '+a.Name AS AgencyName,
                isnull(dbo.PhoneSales.CardPaymentFee, 0) CardFee,
                dbo.PhoneSales.Tax,
                (ISNULL(SUM(dbo.PhoneSales.SellingValue), 0) * SUM(dbo.PhoneSales.Tax) / 100) TaxUsd,
                isnull(pp.Usd, 0) PhonePlanUsd,
                isnull(pp.Usd, 0) + dbo.PhoneSales.SellingValue + isnull(dbo.PhoneSales.CardPaymentFee, 0) + ((ISNULL(SUM(dbo.PhoneSales.SellingValue), 0) * SUM(dbo.PhoneSales.Tax) / 100)) Total
		 FROM dbo.PhoneSales
              INNER JOIN InventoryByAgency ia ON dbo.PhoneSales.InventoryByAgencyId = IA.InventoryByAgencyId
              INNER JOIN  Inventory i ON ia.InventoryId = i.InventoryId
              INNER JOIN dbo.Users ON dbo.PhoneSales.CreatedBy = dbo.Users.UserId
              INNER JOIN Agencies a ON ia.AgencyId = a.AgencyId
              LEFT OUTER JOIN PhonePlans pp ON pp.PhonePlanId = dbo.PhoneSales.PhonePlanId
         WHERE ia.InventoryId = CASE
                                    WHEN @InventoryId IS NULL
                                    THEN ia.InventoryId
                                    ELSE @InventoryId
                                END
               AND CAST(dbo.PhoneSales.CreationDate AS DATE) = CASE
                                                                   WHEN @CreationDate IS NULL
                                                                   THEN CAST(dbo.PhoneSales.CreationDate AS DATE)
                                                                   ELSE CAST(@CreationDate AS DATE)
                                                               END
               AND ia.AgencyId = @AgencyId
               OR @AgencyId IS NULL

			Group by dbo.PhoneSales.PhoneSalesId ,  i.InventoryId , i.PurchaseValue,
                dbo.PhoneSales.SellingValue,
                dbo.PhoneSales.CreationDate,
                dbo.PhoneSales.CreatedBy,
                dbo.PhoneSales.Imei,
                i.Model,
                dbo.Users.Name, a.Code+' - '+a.Name,
			 dbo.PhoneSales.CardPaymentFee,
			 dbo.PhoneSales.Tax,
			 pp.Usd
     END;
GO