CREATE TABLE [dbo].[CardBanksXBankAccounts] (
  [CardBanksXBankAccountsId] [int] IDENTITY,
  [BankAccountId] [int] NOT NULL,
  [CardBankId] [int] NOT NULL,
  PRIMARY KEY CLUSTERED ([CardBanksXBankAccountsId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[CardBanksXBankAccounts]
  ADD CONSTRAINT [FK_CardBanksXBankAccounts_BankAccounts] FOREIGN KEY ([BankAccountId]) REFERENCES [dbo].[BankAccounts] ([BankAccountId])
GO

ALTER TABLE [dbo].[CardBanksXBankAccounts]
  ADD CONSTRAINT [FK_CardBanksXBankAccounts_CardBanks] FOREIGN KEY ([CardBankId]) REFERENCES [dbo].[CardBanks] ([CardBankId])
GO