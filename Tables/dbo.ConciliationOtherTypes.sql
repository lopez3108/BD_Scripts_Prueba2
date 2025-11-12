CREATE TABLE [dbo].[ConciliationOtherTypes] (
  [ConciliationOtherTypeId] [int] IDENTITY,
  [Code] [varchar](4) NOT NULL,
  [Description] [varchar](20) NOT NULL,
  PRIMARY KEY CLUSTERED ([ConciliationOtherTypeId])
)
ON [PRIMARY]
GO