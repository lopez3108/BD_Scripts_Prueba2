CREATE TABLE [dbo].[MoneyTransfers] (
  [MoneyTransfersId] [int] IDENTITY,
  [ProviderId] [int] NOT NULL,
  [Transactions] [int] NULL,
  [TotalTransactions] [int] NULL,
  [Usd] [decimal](18, 2) NULL,
  [TransactionsNumberMoneyOrders] [int] NULL,
  [UsdMoneyOrders] [decimal](18, 2) NULL,
  [CreatedBy] [int] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [DailyId] [int] NULL,
  [MoneyOrderFee] [decimal](18, 2) NULL,
  [ProviderMoneyCommission] [decimal](18, 2) NULL,
  [LastUpdatedOn] [datetime] NULL,
  [LastUpdatedBy] [int] NULL,
  [AcceptNegative] [bit] NULL,
  [DetailedTransaction] [bit] NULL,
  [MoneyOrderService] [bit] NULL,
  [ProviderService] [int] NULL,
  [OnlyNegative] [bit] NULL,
  CONSTRAINT [PK_MoneyTransfers] PRIMARY KEY CLUSTERED ([MoneyTransfersId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[MoneyTransfers]
  ADD CONSTRAINT [FK_MoneyTransfers_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[MoneyTransfers]
  ADD CONSTRAINT [FK_MoneyTransfers_Providers] FOREIGN KEY ([ProviderId]) REFERENCES [dbo].[Providers] ([ProviderId])
GO

ALTER TABLE [dbo].[MoneyTransfers]
  ADD CONSTRAINT [FK_MoneyTransfers_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Indicate if the provider allowed negative at the moment that transaction was created', 'SCHEMA', N'dbo', 'TABLE', N'MoneyTransfers', 'COLUMN', N'AcceptNegative'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Indicate if the provider allowed detailes at the moment that transaction was created', 'SCHEMA', N'dbo', 'TABLE', N'MoneyTransfers', 'COLUMN', N'DetailedTransaction'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Indicate if the provider allowed money order service at the moment that transaction was created', 'SCHEMA', N'dbo', 'TABLE', N'MoneyTransfers', 'COLUMN', N'MoneyOrderService'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Indicate if the provider allowed negative at the moment that transaction was created', 'SCHEMA', N'dbo', 'TABLE', N'MoneyTransfers', 'COLUMN', N'OnlyNegative'
GO