CREATE TABLE [dbo].[CashAdvanceOrBack] (
  [CashAdvanceOrBackId] [int] IDENTITY,
  [ProviderId] [int] NOT NULL,
  [TransactionId] [varchar](30) NULL,
  [Usd] [decimal](18, 2) NULL,
  [Voucher] [varchar](50) NULL,
  [CreatedBy] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [LastUpdatedOn] [datetime] NULL,
  [LastUpdatedBy] [int] NULL,
  CONSTRAINT [PK_CashAdvanceOrBack] PRIMARY KEY CLUSTERED ([CashAdvanceOrBackId]),
  CONSTRAINT [IX_CashAdvanceOrBack_TransactionId] UNIQUE ([TransactionId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[CashAdvanceOrBack]
  ADD CONSTRAINT [FK_CashAdvanceOrBack_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[CashAdvanceOrBack]
  ADD CONSTRAINT [FK_CashAdvanceOrBack_Providers] FOREIGN KEY ([ProviderId]) REFERENCES [dbo].[Providers] ([ProviderId])
GO

ALTER TABLE [dbo].[CashAdvanceOrBack]
  ADD CONSTRAINT [FK_CashAdvanceOrBack_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO