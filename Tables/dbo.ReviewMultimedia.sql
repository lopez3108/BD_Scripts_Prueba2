CREATE TABLE [dbo].[ReviewMultimedia] (
  [ReviewMultimediaId] [int] IDENTITY,
  [ReviewId] [int] NULL,
  [ReviewQuestionsId] [int] NULL,
  [DocumentNameMultimedia] [varchar](500) NOT NULL,
  [IsImage] [bit] NULL CONSTRAINT [DF_ReviewMultimedia_IsImage] DEFAULT (0),
  CONSTRAINT [PK_ReviewMultimedia] PRIMARY KEY CLUSTERED ([ReviewMultimediaId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[ReviewMultimedia]
  ADD CONSTRAINT [FK_ReviewMultimedia_ReviewId] FOREIGN KEY ([ReviewId]) REFERENCES [dbo].[Reviews] ([ReviewId])
GO