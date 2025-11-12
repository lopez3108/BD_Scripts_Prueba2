CREATE TABLE [dbo].[Lendify] (
  [LendifyId] [int] IDENTITY,
  [Name] [varchar](60) NOT NULL,
  [Telephone] [varchar](10) NOT NULL,
  [LendifyStatusId] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [AprovedDate] [datetime] NULL,
  [AprovedBy] [int] NULL,
  [ComissionCashier] [decimal](18, 2) NULL,
  [CommissionAgency] [decimal](18, 2) NULL,
  [ExpenseId] [int] NULL,
  CONSTRAINT [PK_Lendify] PRIMARY KEY CLUSTERED ([LendifyId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[Lendify]
  ADD FOREIGN KEY ([ExpenseId]) REFERENCES [dbo].[Expenses] ([ExpenseId])
GO