CREATE TABLE [dbo].[ConciliationVentras] (
  [ConciliationVentraId] [int] IDENTITY,
  [AgencyId] [int] NOT NULL,
  [BankAccountId] [int] NOT NULL,
  [Date] [datetime] NOT NULL,
  [IsCredit] [bit] NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  PRIMARY KEY CLUSTERED ([ConciliationVentraId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[ConciliationVentras]
  ADD CONSTRAINT [FK_ConciliationVentras_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[ConciliationVentras]
  ADD CONSTRAINT [FK_ConciliationVentras_BankAccounts] FOREIGN KEY ([BankAccountId]) REFERENCES [dbo].[BankAccounts] ([BankAccountId])
GO

ALTER TABLE [dbo].[ConciliationVentras]
  ADD CONSTRAINT [FK_ConciliationVentras_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO