CREATE TABLE [dbo].[Reasons] (
  [ReasonId] [int] IDENTITY,
  [Code] [varchar](10) NOT NULL,
  [Description] [varchar](50) NOT NULL,
  CONSTRAINT [PK_Reasons] PRIMARY KEY CLUSTERED ([ReasonId]),
  CONSTRAINT [IX_Reasons] UNIQUE ([Code])
)
ON [PRIMARY]
GO