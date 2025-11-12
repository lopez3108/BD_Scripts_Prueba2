SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllDiscountsByDate]
(@From      DATE,
 @To        DATE,
 @AgencyId  INT,
 @CreatedBy INT
)
AS
     BEGIN
         SELECT SUM(dbo.DiscountChecks.Discount) AS USD,
                CAST(dbo.DiscountChecks.CreationDate AS DATE) AS Date,
                'DISCOUNT CHECKS' AS Name
         FROM dbo.DiscountChecks
         WHERE CAST(dbo.DiscountChecks.CreationDate AS DATE) >= CAST(@From AS DATE)
               AND CAST(dbo.DiscountChecks.CreationDate AS DATE) <= CAST(@To AS DATE)
               AND CreatedBy = @CreatedBy
               AND AgencyId = @AgencyId
         GROUP BY CAST(dbo.DiscountChecks.CreationDate AS DATE)
         UNION ALL
         SELECT SUM(dbo.DiscountMoneyTransfers.Discount) AS USD,
                CAST(dbo.DiscountMoneyTransfers.CreationDate AS DATE) AS Date,
                'DISCOUNT MONEY TRANSFERS' AS Name
         FROM dbo.DiscountMoneyTransfers
         WHERE CAST(dbo.DiscountMoneyTransfers.CreationDate AS DATE) >= CAST(@From AS DATE)
               AND CAST(dbo.DiscountMoneyTransfers.CreationDate AS DATE) <= CAST(@To AS DATE)
               AND CreatedBy = @CreatedBy
               AND AgencyId = @AgencyId
         GROUP BY CAST(dbo.DiscountMoneyTransfers.CreationDate AS DATE)
         UNION ALL
         SELECT SUM(dbo.DiscountPhones.Discount) AS USD,
                CAST(dbo.DiscountPhones.CreationDate AS DATE) AS Date,
                'DISCOUNT PHONES' AS Name
         FROM dbo.DiscountPhones
         WHERE CAST(dbo.DiscountPhones.CreationDate AS DATE) >= CAST(@From AS DATE)
               AND CAST(dbo.DiscountPhones.CreationDate AS DATE) <= CAST(@To AS DATE)
               AND CreatedBy = @CreatedBy
               AND AgencyId = @AgencyId
         GROUP BY CAST(dbo.DiscountPhones.CreationDate AS DATE)
         UNION ALL
         SELECT SUM(dbo.DiscountTitles.Discount) AS USD,
                CAST(dbo.DiscountTitles.CreationDate AS DATE) AS Date,
                'DISCOUNT TITLES AND PLATES' AS Name
         FROM dbo.DiscountTitles
         WHERE CAST(dbo.DiscountTitles.CreationDate AS DATE) >= CAST(@From AS DATE)
               AND CAST(dbo.DiscountTitles.CreationDate AS DATE) <= CAST(@To AS DATE)
               AND CreatedBy = @CreatedBy
               AND AgencyId = @AgencyId
         GROUP BY CAST(dbo.DiscountTitles.CreationDate AS DATE)
         UNION ALL
         SELECT SUM(dbo.DiscountCityStickers.Usd) AS USD,
                CAST(dbo.DiscountCityStickers.CreationDate AS DATE) AS Date,
                'DISCOUNT CITY STICKERS' AS Name
         FROM dbo.DiscountCityStickers
         WHERE CAST(dbo.DiscountCityStickers.CreationDate AS DATE) >= CAST(@From AS DATE)
               AND CAST(dbo.DiscountCityStickers.CreationDate AS DATE) <= CAST(@To AS DATE)
               AND CreatedBy = @CreatedBy
               AND AgencyId = @AgencyId
         GROUP BY CAST(dbo.DiscountCityStickers.CreationDate AS DATE)
         UNION ALL
         SELECT SUM(dbo.DiscountPlateStickers.Usd) AS USD,
                CAST(dbo.DiscountPlateStickers.CreationDate AS DATE) AS Date,
                'DISCOUNT REGISTRATION RENEWALS' AS Name
         FROM dbo.DiscountPlateStickers
         WHERE CAST(dbo.DiscountPlateStickers.CreationDate AS DATE) >= CAST(@From AS DATE)
               AND CAST(dbo.DiscountPlateStickers.CreationDate AS DATE) <= CAST(@To AS DATE)
               AND CreatedBy = @CreatedBy
               AND AgencyId = @AgencyId
         GROUP BY CAST(dbo.DiscountPlateStickers.CreationDate AS DATE)
	      UNION ALL
         SELECT -SUM(PromotionalCodes.Usd) AS USD,
                CAST(PromotionalCodesStatus.UsedDate AS DATE) AS Date,
                'DISCOUNT PROMOTIONAL CODES' AS Name
         FROM   PromotionalCodesStatus 
              INNER JOIN PromotionalCodes  ON PromotionalCodes.PromotionalCodeId = PromotionalCodesStatus.PromotionalCodeId
         WHERE CAST(dbo.PromotionalCodesStatus.UsedDate AS DATE) >= CAST(@From AS DATE)
               AND CAST(dbo.PromotionalCodesStatus.UsedDate AS DATE) <= CAST(@To AS DATE)
               AND PromotionalCodesStatus.UserUsedId = @CreatedBy
               AND PromotionalCodesStatus.AgencyUsedId = @AgencyId
         GROUP BY CAST(dbo.PromotionalCodesStatus.UsedDate AS DATE);
     END;
GO