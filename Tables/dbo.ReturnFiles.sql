CREATE TABLE [dbo].[ReturnFiles] (
  [ReturnFilesId] [int] IDENTITY,
  [ReturnedCheckId] [int] NOT NULL,
  [Name] [varchar](100) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL
)
ON [PRIMARY]
GO