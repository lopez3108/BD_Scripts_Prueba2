CREATE TABLE [dbo].[PaymentBanksToBanks] (
  [PaymentBanksToBankId] [int] IDENTITY,
  [FromBankAccountId] [int] NOT NULL,
  [ToBankAccountId] [int] NOT NULL,
  [Date] [datetime] NOT NULL,
  [USD] [decimal](18, 2) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  PRIMARY KEY CLUSTERED ([PaymentBanksToBankId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[PaymentBanksToBanks]
  ADD CONSTRAINT [FK_PaymentBanksToBanks_BankAccounts] FOREIGN KEY ([ToBankAccountId]) REFERENCES [dbo].[BankAccounts] ([BankAccountId])
GO

ALTER TABLE [dbo].[PaymentBanksToBanks]
  ADD CONSTRAINT [FK_PaymentBanksToBanks_BankAccounts1] FOREIGN KEY ([FromBankAccountId]) REFERENCES [dbo].[BankAccounts] ([BankAccountId])
GO