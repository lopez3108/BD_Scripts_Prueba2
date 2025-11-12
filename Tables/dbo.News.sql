CREATE TABLE [dbo].[News] (
  [NewsId] [int] IDENTITY,
  [Description] [varchar](400) NOT NULL,
  [DocumentName] [varchar](600) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  CONSTRAINT [PK_News] PRIMARY KEY CLUSTERED ([NewsId])
)
ON [PRIMARY]
GO