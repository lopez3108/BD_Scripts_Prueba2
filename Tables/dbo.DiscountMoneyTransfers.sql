CREATE TABLE [dbo].[DiscountMoneyTransfers] (
  [DiscountMoneyTransferId] [int] IDENTITY,
  [ProviderId] [int] NOT NULL,
  [Number] [varchar](10) NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  [Fee] [decimal](18, 2) NOT NULL,
  [Discount] [decimal](18, 2) NOT NULL,
  [ActualClient] [varchar](50) NOT NULL,
  [ReferedClient] [varchar](50) NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [IsActualClient] [bit] NOT NULL CONSTRAINT [DF__DiscountM__IsAct__3A2D78C3] DEFAULT (0),
  [LastUpdatedOn] [datetime] NULL,
  [LastUpdatedBy] [int] NULL,
  [ActualClientTelephone] [varchar](10) NOT NULL,
  [TelIsCheck] [bit] NULL CONSTRAINT [DF_DiscountMoneyTransfers_TelIsCheck] DEFAULT (0),
  CONSTRAINT [PK_DiscountMoneyTransfers] PRIMARY KEY CLUSTERED ([DiscountMoneyTransferId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[DiscountMoneyTransfers]
  ADD CONSTRAINT [FK_DiscountMoneyTransfers_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[DiscountMoneyTransfers]
  ADD CONSTRAINT [FK_DiscountMoneyTransfers_Providers] FOREIGN KEY ([ProviderId]) REFERENCES [dbo].[Providers] ([ProviderId])
GO

ALTER TABLE [dbo].[DiscountMoneyTransfers]
  ADD CONSTRAINT [FK_DiscountMoneyTransfers_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO