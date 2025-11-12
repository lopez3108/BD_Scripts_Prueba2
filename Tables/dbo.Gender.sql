CREATE TABLE [dbo].[Gender] (
  [GenderId] [int] IDENTITY,
  [Description] [varchar](30) NOT NULL,
  [Code] [varchar](10) NOT NULL,
  CONSTRAINT [PK_Gender] PRIMARY KEY CLUSTERED ([GenderId])
)
ON [PRIMARY]
GO