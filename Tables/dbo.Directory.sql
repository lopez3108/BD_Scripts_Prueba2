CREATE TABLE [dbo].[Directory] (
  [DirectoryId] [int] IDENTITY,
  [Company] [varchar](100) NOT NULL,
  [Telephone] [varchar](50) NOT NULL,
  [Extension] [varchar](20) NULL,
  [Department] [varchar](50) NOT NULL,
  [Fax] [varchar](15) NULL,
  [Email] [varchar](100) NULL,
  PRIMARY KEY CLUSTERED ([DirectoryId])
)
ON [PRIMARY]
GO