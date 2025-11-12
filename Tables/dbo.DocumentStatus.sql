CREATE TABLE [dbo].[DocumentStatus] (
  [DocumentStatusId] [int] IDENTITY,
  [Description] [varchar](30) NOT NULL,
  [Code] [varchar](10) NOT NULL,
  CONSTRAINT [PK_DocumentStatus] PRIMARY KEY CLUSTERED ([DocumentStatusId])
)
ON [PRIMARY]
GO