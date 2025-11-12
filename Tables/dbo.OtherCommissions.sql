CREATE TABLE [dbo].[OtherCommissions] (
  [OtherCommissionId] [int] IDENTITY,
  [ProviderCommissionPaymentId] [int] NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  [Description] [varchar](100) NOT NULL,
  [ProviderCommissionPaymentTypeId] [int] NOT NULL,
  [AchDate] [datetime] NULL,
  [AdjustmentDate] [datetime] NULL,
  [CheckNumber] [varchar](15) NULL,
  [CheckDate] [datetime] NULL,
  [CurrentDate] [datetime] NULL,
  [BankId] [int] NULL,
  [Account] [varchar](4) NULL,
  [ValidatedOn] [datetime] NULL,
  [ValidatedBy] [int] NULL,
  [BankAccountId] [int] NULL,
  [LotNumber] [smallint] NULL,
  [PaymentChecksAgentToAgentId] [int] NULL,
  [ProccesCheckReturned] [bit] NULL,
  CONSTRAINT [PK_OtherCommissions] PRIMARY KEY CLUSTERED ([OtherCommissionId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[OtherCommissions]
  ADD CONSTRAINT [FK_OtherCommissions_BankAccountId] FOREIGN KEY ([BankAccountId]) REFERENCES [dbo].[BankAccounts] ([BankAccountId])
GO

ALTER TABLE [dbo].[OtherCommissions] WITH NOCHECK
  ADD CONSTRAINT [FK_OtherCommissions_PaymentChecksAgentToAgent] FOREIGN KEY ([PaymentChecksAgentToAgentId]) REFERENCES [dbo].[PaymentChecksAgentToAgent] ([PaymentChecksAgentToAgentId]) NOT FOR REPLICATION
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Número de lote por fecha y por userId', 'SCHEMA', N'dbo', 'TABLE', N'OtherCommissions', 'COLUMN', N'LotNumber'
GO