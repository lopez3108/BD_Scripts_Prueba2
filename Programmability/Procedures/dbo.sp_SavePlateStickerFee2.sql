SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SavePlateStickerFee2]
(@PlateStickerFee2Id INT            = NULL,
 @Usd                DECIMAL(18, 2),
 @UsdLessEqualValue  DECIMAL(18, 2),
 @UsdGreaterValue    DECIMAL(18, 2),
 @ProviderElsId      INT
)
AS
     BEGIN
         IF(@PlateStickerFee2Id IS NULL)
             BEGIN
                 INSERT INTO [dbo].[PlateStickersFee2]
                 (Usd,
                  UsdLessEqualValue,
                  UsdGreaterValue,
                  ProviderElsId
                 )
                 VALUES
                 (@Usd,
                  @UsdLessEqualValue,
                  @UsdGreaterValue,
                  @ProviderElsId
                 );
			
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].[PlateStickersFee2]
                   SET
                       Usd = @Usd,
                       UsdLessEqualValue = @UsdLessEqualValue,
                       UsdGreaterValue = @UsdGreaterValue,
                       ProviderElsId = @ProviderElsId
                 WHERE PlateStickerFee2Id = @PlateStickerFee2Id;
			 
         END;
     END;
GO