CREATE TABLE [dbo].[MoneyOrders] (
  [MoneyOrderId] [int] IDENTITY,
  [ProviderId] [int] NOT NULL,
  [DailyId] [int] NOT NULL,
  [Transactions] [int] NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [AgencyId] [int] NOT NULL,
  CONSTRAINT [PK_MoneyOrders] PRIMARY KEY CLUSTERED ([MoneyOrderId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[MoneyOrders]
  ADD CONSTRAINT [FK_MoneyOrders_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[MoneyOrders]
  ADD CONSTRAINT [FK_MoneyOrders_Daily] FOREIGN KEY ([DailyId]) REFERENCES [dbo].[Daily] ([DailyId])
GO

ALTER TABLE [dbo].[MoneyOrders]
  ADD CONSTRAINT [FK_MoneyOrders_Providers] FOREIGN KEY ([ProviderId]) REFERENCES [dbo].[Providers] ([ProviderId])
GO

ALTER TABLE [dbo].[MoneyOrders]
  ADD CONSTRAINT [FK_MoneyOrders_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO