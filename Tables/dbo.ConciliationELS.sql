CREATE TABLE [dbo].[ConciliationELS] (
  [ConciliationELSId] [int] IDENTITY,
  [AgencyId] [int] NOT NULL,
  [BankAccountId] [int] NOT NULL,
  [FromDate] [datetime] NOT NULL,
  [ToDate] [datetime] NOT NULL,
  [IsCredit] [bit] NULL,
  [IsDebit] [bit] NULL,
  [IsCommissionPayments] [bit] NULL,
  [CreatedBy] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  CONSTRAINT [PK__Concilia__FABF3C4DFE21AC99] PRIMARY KEY CLUSTERED ([ConciliationELSId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[ConciliationELS]
  ADD CONSTRAINT [FK_ConciliationELS_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[ConciliationELS]
  ADD CONSTRAINT [FK_ConciliationELS_BankAccounts] FOREIGN KEY ([BankAccountId]) REFERENCES [dbo].[BankAccounts] ([BankAccountId])
GO

ALTER TABLE [dbo].[ConciliationELS]
  ADD CONSTRAINT [FK_ConciliationELS_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO