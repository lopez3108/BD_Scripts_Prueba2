CREATE TABLE [dbo].[Notary] (
  [NotaryId] [int] IDENTITY,
  [Quantity] [int] NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [UpdatedOn] [datetime] NULL,
  [UpdatedBy] [int] NULL,
  [ValidatedBy] [int] NULL,
  [ValidatedOn] [datetime] NULL,
  [ExpenseId] [int] NULL,
  CONSTRAINT [PK_Notary] PRIMARY KEY CLUSTERED ([NotaryId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[Notary]
  ADD FOREIGN KEY ([ExpenseId]) REFERENCES [dbo].[Expenses] ([ExpenseId])
GO

ALTER TABLE [dbo].[Notary]
  ADD CONSTRAINT [FK_Notary_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[Notary]
  ADD CONSTRAINT [FK_Notary_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO