CREATE TABLE [dbo].[Files] (
  [FileId] [int] IDENTITY,
  [Name] [varchar](50) NOT NULL,
  [Description] [varchar](300) NOT NULL,
  [Location] [varchar](300) NOT NULL,
  [UploadedBy] [int] NOT NULL,
  [DateUploaded] [datetime] NOT NULL,
  CONSTRAINT [PK_Files] PRIMARY KEY CLUSTERED ([FileId])
)
ON [PRIMARY]
GO