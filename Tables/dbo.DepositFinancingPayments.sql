CREATE TABLE [dbo].[DepositFinancingPayments] (
  [DepositFinancingPaymentsId] [int] IDENTITY,
  [ContractId] [int] NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [AgencyId] [int] NULL,
  [CardPayment] [bit] NOT NULL CONSTRAINT [DF_DepositFinancingPayments_CardPayment] DEFAULT (0),
  [CardPaymentFee] [decimal](18, 2) NULL,
  [Cash] [decimal](18, 2) NULL,
  [BankAccountId] [int] NULL,
  [AchDate] [datetime] NULL,
  CONSTRAINT [PK_DepositFinancingPayments] PRIMARY KEY CLUSTERED ([DepositFinancingPaymentsId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[DepositFinancingPayments]
  ADD CONSTRAINT [FK_DepositFinancingPayments_BankAccountId] FOREIGN KEY ([BankAccountId]) REFERENCES [dbo].[BankAccounts] ([BankAccountId])
GO

ALTER TABLE [dbo].[DepositFinancingPayments]
  ADD CONSTRAINT [FKDepositFinancingPayments_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[DepositFinancingPayments]
  ADD CONSTRAINT [FKDepositFinancingPayments_Contract] FOREIGN KEY ([ContractId]) REFERENCES [dbo].[Contract] ([ContractId])
GO