CREATE TABLE [dbo].[CourtPayment] (
  [CourtPaymentId] [int] IDENTITY,
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
  CONSTRAINT [PK_CourtPayments] PRIMARY KEY CLUSTERED ([CourtPaymentId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[CourtPayment]
  ADD CONSTRAINT [FK_CourtPayment_BankAccountId] FOREIGN KEY ([BankAccountId]) REFERENCES [dbo].[BankAccounts] ([BankAccountId])
GO

ALTER TABLE [dbo].[CourtPayment]
  ADD CONSTRAINT [FK_CourtPayment_CardBanks] FOREIGN KEY ([CardBankId]) REFERENCES [dbo].[CardBanks] ([CardBankId])
GO