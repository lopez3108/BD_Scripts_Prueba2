CREATE TABLE [dbo].[LawyerPayments] (
  [LawyerPaymentId] [int] IDENTITY,
  [ReturnedCheckId] [int] NOT NULL,
  [ProviderCommissionPaymentTypeId] [int] NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  [CheckNumber] [varchar](15) NULL,
  [CheckDate] [datetime] NULL,
  [BankAccountId] [int] NULL,
  [CardBankId] [int] NULL,
  [AgencyId] [int] NULL,
  [MoneyOrderNumber] [varchar](20) NULL,
  [AchDate] [datetime] NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [LastUpdatedOn] [datetime] NULL,
  [LastUpdatedBy] [int] NULL,
  CONSTRAINT [PK_LawyerPayments] PRIMARY KEY CLUSTERED ([LawyerPaymentId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[LawyerPayments]
  ADD CONSTRAINT [FK_LawyerPayments_BankAccountId] FOREIGN KEY ([BankAccountId]) REFERENCES [dbo].[BankAccounts] ([BankAccountId])
GO

ALTER TABLE [dbo].[LawyerPayments]
  ADD CONSTRAINT [FK_LawyerPayments_CardBanks] FOREIGN KEY ([CardBankId]) REFERENCES [dbo].[CardBanks] ([CardBankId])
GO