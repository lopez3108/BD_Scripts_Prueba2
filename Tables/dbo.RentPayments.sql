CREATE TABLE [dbo].[RentPayments] (
  [RentPaymentId] [int] IDENTITY,
  [ContractId] [int] NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  [UsdPayment] [decimal](18, 2) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [AgencyId] [int] NULL,
  [CardPayment] [bit] NOT NULL CONSTRAINT [DF_RentPayments_CardPayment] DEFAULT (0),
  [CardPaymentFee] [decimal](18, 2) NULL,
  [FeeDue] [decimal](18, 2) NULL,
  [Cash] [decimal](18, 2) NULL,
  [BankAccountId] [int] NULL,
  [FeeDuePending] [decimal](18, 2) NULL,
  [RentPending] [decimal](18, 2) NULL,
  [InitialBalance] [decimal](18, 2) NULL,
  [FinalBalance] [decimal](18, 2) NULL,
  [MoveInFee] [decimal](18, 2) NULL DEFAULT (0),
  [AchDate] [datetime] NULL,
  [IsCredit] [bit] NULL,
  CONSTRAINT [PK_RentPayments] PRIMARY KEY CLUSTERED ([RentPaymentId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[RentPayments]
  ADD CONSTRAINT [FK_RentPayments_BankAccountId] FOREIGN KEY ([BankAccountId]) REFERENCES [dbo].[BankAccounts] ([BankAccountId])
GO

ALTER TABLE [dbo].[RentPayments]
  ADD CONSTRAINT [FKRentPayments_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[RentPayments]
  ADD CONSTRAINT [FKRentPayments_Contract] FOREIGN KEY ([ContractId]) REFERENCES [dbo].[Contract] ([ContractId])
GO