CREATE TABLE [dbo].[DocumentInformation] (
  [DocumentId] [int] IDENTITY,
  [Name] [varchar](60) NULL,
  [Telephone] [varchar](14) NULL,
  [Note] [varchar](100) NULL,
  [CreatedDate] [datetime] NULL,
  [CreatedBy] [int] NULL,
  [UpdatedBy] [int] NULL,
  [UpdatedOn] [datetime] NULL,
  [AgencyId] [int] NULL,
  [Doc1Birth] [datetime] NULL,
  [ValidatedBy] [int] NULL,
  [ValidatedOn] [datetime] NULL,
  CONSTRAINT [PK_DocumentInformation] PRIMARY KEY CLUSTERED ([DocumentId])
)
ON [PRIMARY]
GO

CREATE FULLTEXT INDEX
  ON [dbo].[DocumentInformation]([Name] LANGUAGE 1033)
  KEY INDEX [PK_DocumentInformation]
  ON [FullTextCatalog]
  WITH CHANGE_TRACKING AUTO, STOPLIST SYSTEM
GO