CREATE TABLE [dbo].[ConciliationOthers] (
  [ConciliationOtherId] [int] IDENTITY,
  [ConciliationOtherTypeId] [int] NOT NULL,
  [AgencyId] [int] NULL,
  [BankAccountId] [int] NOT NULL,
  [Date] [datetime] NOT NULL,
  [IsCredit] [bit] NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  [CapitalUsd] [decimal](18, 2) NULL,
  [InterestUsd] [decimal](18, 2) NULL,
  [CreatedBy] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [Description] [varchar](60) NULL,
  [ExpenseBankStatusId] [int] NULL,
  [CompletedBy] [int] NULL,
  [CompletedOn] [datetime] NULL,
  [LastUpdatedBy] [int] NULL,
  [LastUpdatedOn] [datetime] NULL,
  PRIMARY KEY CLUSTERED ([ConciliationOtherId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[ConciliationOthers]
  ADD CONSTRAINT [FK_ConciliationOthers_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[ConciliationOthers]
  ADD CONSTRAINT [FK_ConciliationOthers_BankAccounts] FOREIGN KEY ([BankAccountId]) REFERENCES [dbo].[BankAccounts] ([BankAccountId])
GO

ALTER TABLE [dbo].[ConciliationOthers]
  ADD CONSTRAINT [FK_ConciliationOthers_CompletedBy] FOREIGN KEY ([CompletedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[ConciliationOthers]
  ADD CONSTRAINT [FK_ConciliationOthers_ConciliationOtherTypes] FOREIGN KEY ([ConciliationOtherTypeId]) REFERENCES [dbo].[ConciliationOtherTypes] ([ConciliationOtherTypeId])
GO

ALTER TABLE [dbo].[ConciliationOthers]
  ADD CONSTRAINT [FK_ConciliationOthers_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO