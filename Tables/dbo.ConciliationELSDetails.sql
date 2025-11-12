CREATE TABLE [dbo].[ConciliationELSDetails] (
  [ConciliationELSDetailId] [int] IDENTITY,
  [ConciliationELSId] [int] NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  PRIMARY KEY CLUSTERED ([ConciliationELSDetailId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[ConciliationELSDetails]
  ADD CONSTRAINT [FK_ConciliationELSDetails_ConciliationELS] FOREIGN KEY ([ConciliationELSId]) REFERENCES [dbo].[ConciliationELS] ([ConciliationELSId])
GO