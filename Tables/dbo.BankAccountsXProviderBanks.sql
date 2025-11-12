CREATE TABLE [dbo].[BankAccountsXProviderBanks] (
  [BankAccountsXProviderBankId] [int] IDENTITY,
  [BankAccountId] [int] NOT NULL,
  [AccountOwnerId] [int] NOT NULL,
  PRIMARY KEY CLUSTERED ([BankAccountsXProviderBankId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[BankAccountsXProviderBanks]
  ADD CONSTRAINT [FK_BankAccountsXProviderBanks_BankAccountId] FOREIGN KEY ([BankAccountId]) REFERENCES [dbo].[BankAccounts] ([BankAccountId])
GO