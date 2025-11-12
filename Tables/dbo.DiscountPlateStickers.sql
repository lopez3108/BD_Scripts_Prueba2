CREATE TABLE [dbo].[DiscountPlateStickers] (
  [DiscountPlateStickerId] [int] IDENTITY,
  [Usd] [decimal](18, 2) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [LastUpdatedOn] [datetime] NULL,
  [LastUpdatedBy] [int] NULL,
  [ActualClientTelephone] [varchar](10) NOT NULL,
  [TelIsCheck] [bit] NULL CONSTRAINT [DF_DiscountPlateStickers_TelIsCheck] DEFAULT (0),
  [Discount] [decimal](18, 2) NULL,
  CONSTRAINT [PK_DiscountPlateStickers] PRIMARY KEY CLUSTERED ([DiscountPlateStickerId])
)
ON [PRIMARY]
GO