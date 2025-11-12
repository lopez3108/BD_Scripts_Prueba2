CREATE TABLE [dbo].[ConciliationSalesTaxes] (
  [ConciliationSalesTaxId] [int] IDENTITY,
  [Date] [datetime] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [BankAccountId] [int] NOT NULL,
  [FromDate] [datetime] NOT NULL,
  [ToDate] [datetime] NOT NULL,
  [IsCredit] [bit] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  CONSTRAINT [PK_ConciliationSalesTaxes] PRIMARY KEY CLUSTERED ([ConciliationSalesTaxId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[ConciliationSalesTaxes]
  ADD CONSTRAINT [FK_ConciliationSalesTaxes_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[ConciliationSalesTaxes]
  ADD CONSTRAINT [FK_ConciliationSalesTaxes_BankAccounts] FOREIGN KEY ([BankAccountId]) REFERENCES [dbo].[BankAccounts] ([BankAccountId])
GO

ALTER TABLE [dbo].[ConciliationSalesTaxes]
  ADD CONSTRAINT [FK_ConciliationSalesTaxes_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO