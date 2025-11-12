CREATE TABLE [dbo].[NotesXTitles] (
  [NotesXTitleId] [int] IDENTITY,
  [TitleId] [int] NOT NULL,
  [Note] [varchar](400) NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [CreatedOn] [datetime] NOT NULL,
  [IsPrincipalNote] [bit] NULL,
  CONSTRAINT [PK_NotesxTitle] PRIMARY KEY CLUSTERED ([NotesXTitleId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[NotesXTitles]
  ADD CONSTRAINT [FK_NotesXTitles_Titles] FOREIGN KEY ([TitleId]) REFERENCES [dbo].[Titles] ([TitleId])
GO

ALTER TABLE [dbo].[NotesXTitles]
  ADD CONSTRAINT [FK_NotesXTitles_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO