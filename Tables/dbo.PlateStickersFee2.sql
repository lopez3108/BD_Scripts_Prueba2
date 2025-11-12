CREATE TABLE [dbo].[PlateStickersFee2] (
  [PlateStickerFee2Id] [int] IDENTITY,
  [Usd] [decimal](18, 2) NOT NULL,
  [UsdLessEqualValue] [decimal](18, 2) NOT NULL,
  [UsdGreaterValue] [decimal](18, 2) NOT NULL,
  [ProviderElsId] [int] NOT NULL,
  CONSTRAINT [PK_PlateStickersFee2] PRIMARY KEY CLUSTERED ([PlateStickerFee2Id]),
  CONSTRAINT [IX_PlateStickersFee2] UNIQUE ([ProviderElsId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[PlateStickersFee2]
  ADD CONSTRAINT [FK_PlateStickersFee2_ProvidersEls] FOREIGN KEY ([ProviderElsId]) REFERENCES [dbo].[ProvidersEls] ([ProviderElsId])
GO