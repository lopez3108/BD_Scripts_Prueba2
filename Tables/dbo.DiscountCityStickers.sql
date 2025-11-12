CREATE TABLE [dbo].[DiscountCityStickers] (
  [DiscountCityStickerId] [int] IDENTITY,
  [Usd] [decimal](18, 2) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [LastUpdatedOn] [datetime] NULL,
  [LastUpdatedBy] [int] NULL,
  [TelIsCheck] [bit] NULL CONSTRAINT [DF_DiscountCityStickers_TelIsCheck] DEFAULT (0),
  [ActualClientTelephone] [varchar](10) NOT NULL,
  [Discount] [decimal](18, 2) NULL,
  CONSTRAINT [PK_DiscountsCityStickers] PRIMARY KEY CLUSTERED ([DiscountCityStickerId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[DiscountCityStickers]
  ADD CONSTRAINT [FK_DiscountsCityStickers_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO