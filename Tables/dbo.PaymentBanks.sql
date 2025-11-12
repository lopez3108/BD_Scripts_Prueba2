CREATE TABLE [dbo].[PaymentBanks] (
  [PaymentBankId] [int] IDENTITY,
  [BankAccountId] [int] NULL,
  [Date] [datetime] NULL,
  [USD] [decimal](18, 2) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [FileImageName] [varchar](1000) NULL,
  [Status] [int] NULL,
  [AgencyId] [int] NULL,
  [IsDebitCredit] [bit] NULL CONSTRAINT [DF_PaymentBanks_IsDebitCredit] DEFAULT (0),
  CONSTRAINT [PK__PaymentB__817F9D055A51C513] PRIMARY KEY CLUSTERED ([PaymentBankId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[PaymentBanks]
  ADD CONSTRAINT [FK_PaymentBanks_BankAccountId] FOREIGN KEY ([BankAccountId]) REFERENCES [dbo].[BankAccounts] ([BankAccountId])
GO