CREATE TABLE [dbo].[CancellationStatus] (
  [CancellationStatusId] [int] IDENTITY,
  [Description] [varchar](50) NOT NULL,
  [Code] [varchar](10) NOT NULL,
  CONSTRAINT [PK_CancellationTypes] PRIMARY KEY CLUSTERED ([CancellationStatusId])
)
ON [PRIMARY]
GO