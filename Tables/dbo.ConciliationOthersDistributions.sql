CREATE TABLE [dbo].[ConciliationOthersDistributions] (
  [ConciliationOthersDistributionId] [int] IDENTITY,
  [ConciliationOtherId] [int] NOT NULL,
  [AgencyId] [int] NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  PRIMARY KEY CLUSTERED ([ConciliationOthersDistributionId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[ConciliationOthersDistributions]
  ADD CONSTRAINT [FK_ConciliationOthersDistributions_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[ConciliationOthersDistributions]
  ADD CONSTRAINT [FK_ConciliationOthersDistributions_ConciliationOthers] FOREIGN KEY ([ConciliationOtherId]) REFERENCES [dbo].[ConciliationOthers] ([ConciliationOtherId])
GO