CREATE TABLE [dbo].[ProcessStatus] (
  [ProcessStatusId] [int] IDENTITY,
  [Code] [varchar](10) NOT NULL,
  [Description] [varchar](30) NOT NULL,
  [Order] [int] NULL,
  CONSTRAINT [PK_ProcessStatus] PRIMARY KEY CLUSTERED ([ProcessStatusId])
)
ON [PRIMARY]
GO