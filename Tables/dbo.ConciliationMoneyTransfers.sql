CREATE TABLE [dbo].[ConciliationMoneyTransfers] (
  [ConciliationMoneyTransfersId] [int] IDENTITY,
  [ProviderId] [int] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [BankAccountId] [int] NOT NULL,
  [Date] [datetime] NOT NULL,
  [IsCredit] [bit] NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  CONSTRAINT [PK_ConciliationMoneyTransfers] PRIMARY KEY CLUSTERED ([ConciliationMoneyTransfersId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[ConciliationMoneyTransfers]
  ADD CONSTRAINT [FK_ConciliationMoneyTransfers_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[ConciliationMoneyTransfers]
  ADD CONSTRAINT [FK_ConciliationMoneyTransfers_BankAccounts] FOREIGN KEY ([BankAccountId]) REFERENCES [dbo].[BankAccounts] ([BankAccountId])
GO

ALTER TABLE [dbo].[ConciliationMoneyTransfers]
  ADD CONSTRAINT [FK_ConciliationMoneyTransfers_Provider] FOREIGN KEY ([ProviderId]) REFERENCES [dbo].[Providers] ([ProviderId])
GO

ALTER TABLE [dbo].[ConciliationMoneyTransfers]
  ADD CONSTRAINT [FK_ConciliationMoneyTransfers_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO