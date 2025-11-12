CREATE TABLE [dbo].[CancellationTypes] (
  [CancellationTypeId] [int] IDENTITY,
  [Description] [varchar](50) NOT NULL,
  [Code] [varchar](10) NOT NULL,
  CONSTRAINT [PK_CancellationTypes_1] PRIMARY KEY CLUSTERED ([CancellationTypeId])
)
ON [PRIMARY]
GO