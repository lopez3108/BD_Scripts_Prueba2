CREATE TABLE [dbo].[DiscountPhones] (
  [DiscountPhoneId] [int] IDENTITY,
  [PhoneSaleId] [int] NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  [Discount] [decimal](18, 2) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [LastUpdatedOn] [datetime] NULL,
  [LastUpdatedBy] [int] NULL,
  [TelIsCheck] [bit] NULL CONSTRAINT [DF_DiscountPhones_TelIsCheck] DEFAULT (0),
  [ActualClientTelephone] [varchar](10) NOT NULL,
  CONSTRAINT [PK_DiscountPhones] PRIMARY KEY CLUSTERED ([DiscountPhoneId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[DiscountPhones]
  ADD CONSTRAINT [FK_DiscountPhones_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[DiscountPhones]
  ADD CONSTRAINT [FK_DiscountPhones_PhoneSales] FOREIGN KEY ([PhoneSaleId]) REFERENCES [dbo].[PhoneSales] ([PhoneSalesId])
GO

ALTER TABLE [dbo].[DiscountPhones]
  ADD CONSTRAINT [FK_DiscountPhones_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO