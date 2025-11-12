CREATE TABLE [dbo].[ProviderCommissionPayments] (
  [ProviderCommissionPaymentId] [int] IDENTITY,
  [ProviderId] [int] NOT NULL,
  [Month] [int] NOT NULL,
  [Year] [int] NOT NULL,
  [ProviderCommissionPaymentTypeId] [int] NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  [UsdMoneyOrders] [decimal](18, 2) NULL,
  [CheckNumber] [varchar](15) NULL,
  [CheckDate] [datetime] NULL,
  [BankId] [int] NULL,
  [Account] [varchar](4) NULL,
  [AgencyId] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [LastUpdatedDate] [datetime] NULL,
  [LastUpdatedBy] [int] NULL,
  [AchDate] [datetime] NULL,
  [AdjustmentDate] [datetime] NULL,
  [ValidatedOn] [datetime] NULL,
  [ValidatedBy] [int] NULL,
  [BankAccountId] [int] NULL,
  [LotNumber] [smallint] NULL,
  [PaymentChecksAgentToAgentId] [int] NULL,
  [TotalTransactions] [int] NULL,
  [ProccesCheckReturned] [bit] NULL,
  [IsForex] [bit] NULL DEFAULT (0),
  CONSTRAINT [PK_ProviderCommissionPayments] PRIMARY KEY CLUSTERED ([ProviderCommissionPaymentId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[ProviderCommissionPayments]
  ADD CONSTRAINT [FK_ProviderCommissionPayments_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[ProviderCommissionPayments]
  ADD CONSTRAINT [FK_ProviderCommissionPayments_BankAccountId] FOREIGN KEY ([BankAccountId]) REFERENCES [dbo].[BankAccounts] ([BankAccountId])
GO

ALTER TABLE [dbo].[ProviderCommissionPayments] WITH NOCHECK
  ADD CONSTRAINT [FK_ProviderCommissionPayments_PaymentChecksAgentToAgent] FOREIGN KEY ([PaymentChecksAgentToAgentId]) REFERENCES [dbo].[PaymentChecksAgentToAgent] ([PaymentChecksAgentToAgentId]) NOT FOR REPLICATION
GO

ALTER TABLE [dbo].[ProviderCommissionPayments]
  ADD CONSTRAINT [FK_ProviderCommissionPayments_ProviderCommissionPaymentTypes] FOREIGN KEY ([ProviderCommissionPaymentTypeId]) REFERENCES [dbo].[ProviderCommissionPaymentTypes] ([ProviderCommissionPaymentTypeId])
GO

ALTER TABLE [dbo].[ProviderCommissionPayments]
  ADD CONSTRAINT [FK_ProviderCommissionPayments_Providers] FOREIGN KEY ([ProviderId]) REFERENCES [dbo].[Providers] ([ProviderId])
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Número de lote por fecha y por userId', 'SCHEMA', N'dbo', 'TABLE', N'ProviderCommissionPayments', 'COLUMN', N'LotNumber'
GO