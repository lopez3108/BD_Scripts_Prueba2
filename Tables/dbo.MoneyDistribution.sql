CREATE TABLE [dbo].[MoneyDistribution] (
  [MoneyDistributionId] [int] IDENTITY,
  [CashierId] [int] NOT NULL,
  [MoneyTransferxAgencyNumbersId] [int] NULL,
  [IsDefault] [bit] NOT NULL,
  [BankAccountId] [int] NULL,
  [Active] [bit] NOT NULL DEFAULT (1),
  CONSTRAINT [PK_MoneyDistribution] PRIMARY KEY CLUSTERED ([MoneyDistributionId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[MoneyDistribution]
  ADD CONSTRAINT [FK_MoneyDistribution_BankAccountId] FOREIGN KEY ([BankAccountId]) REFERENCES [dbo].[BankAccounts] ([BankAccountId])
GO

ALTER TABLE [dbo].[MoneyDistribution]
  ADD CONSTRAINT [FK_MoneyDistribution_Cashiers] FOREIGN KEY ([CashierId]) REFERENCES [dbo].[Cashiers] ([CashierId])
GO