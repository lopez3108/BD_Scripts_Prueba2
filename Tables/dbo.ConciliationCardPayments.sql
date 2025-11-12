CREATE TABLE [dbo].[ConciliationCardPayments] (
  [ConciliationCardPaymentId] [int] IDENTITY,
  [AgencyId] [int] NOT NULL,
  [BankAccountId] [int] NOT NULL,
  [FromDate] [datetime] NOT NULL,
  [ToDate] [datetime] NOT NULL,
  [IsCredit] [bit] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [MidSaved] [varchar](20) NULL,
  PRIMARY KEY CLUSTERED ([ConciliationCardPaymentId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[ConciliationCardPayments]
  ADD CONSTRAINT [FK_ConciliationCardPayments_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[ConciliationCardPayments]
  ADD CONSTRAINT [FK_ConciliationCardPayments_BankAccounts] FOREIGN KEY ([BankAccountId]) REFERENCES [dbo].[BankAccounts] ([BankAccountId])
GO

ALTER TABLE [dbo].[ConciliationCardPayments]
  ADD CONSTRAINT [FK_ConciliationCardPayments_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO