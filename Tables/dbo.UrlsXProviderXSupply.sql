CREATE TABLE [dbo].[UrlsXProviderXSupply] (
  [UrlXProviderXOfficeSupplyId] [int] IDENTITY,
  [Url] [varchar](400) NULL,
  [OfficeSupplieId] [int] NULL,
  [ProvidersOfficeSuppliesId] [int] NULL,
  CONSTRAINT [PK_UrlsXProviderXSupply] PRIMARY KEY CLUSTERED ([UrlXProviderXOfficeSupplyId])
)
ON [PRIMARY]
GO