SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllProvidersEls](@ProviderElsTypeCode VARCHAR(10) = NULL)
AS
     BEGIN
         SELECT p.ProviderElsId,
                p.Code,
                p.Name,
                p.AllowFee1Default,

				 CASE
                   WHEN p.AllowFee1Default = 1
                   THEN 'YES'
                   ELSE 'NO'
                 END AS [AllowFee1DefaultFormat],

                p.Fee1Default,
                p.AllowFee2,
                p.AllowDefaultUsd,
                p.DefaultUsd,	
                ISNULL(F.PlateStickerFee2Id, 0) PlateStickerFee2Id,
                ISNULL(p.FeeCollect, 0) AS FeeCollect,
                ISNULL(p.FeeELS, 0) AS FeeELS,

					 CASE
                   WHEN p.Code <> 'C02'
                   THEN ISNULL(p.FeeELS, 0)
                   ELSE 0
               END AS [FeeELS1],

				 CASE
                   WHEN p.Code = 'C02'
                   THEN ISNULL(p.FeeELS, 0)
                   ELSE 0
               END AS [FeeELSTrp7],
				ISNULL(p.FeeELSTrp, 0) AS FeeELSTrp,
        ISNULL(p.FeeElsSale, 0) AS FeeElsSale,
        ISNULL(p.FeeElsTrpSale, 0) AS FeeElsTrpSale,
                ISNULL(F.Usd, 0) Fee2DefaultUsd,
                ISNULL(F.UsdLessEqualValue, 0) UsdLessEqualValue,
                ISNULL(F.UsdGreaterValue, 0) UsdGreaterValue,
                ISNULL(F.Usd, 0) Usd
         FROM dbo.ProvidersEls p
              LEFT JOIN PlateStickersFee2 F ON p.ProviderElsId = F.ProviderElsId
         WHERE Code = @ProviderElsTypeCode
               OR @ProviderElsTypeCode IS NULL
               OR @ProviderElsTypeCode = ''
         ORDER BY Name;
     END;
GO