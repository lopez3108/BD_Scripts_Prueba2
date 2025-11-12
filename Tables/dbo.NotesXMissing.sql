CREATE TABLE [dbo].[NotesXMissing] (
  [NotesXMissingId] [int] IDENTITY,
  [CreatedBy] [int] NOT NULL,
  [Note] [varchar](400) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [UserId] [int] NOT NULL,
  PRIMARY KEY CLUSTERED ([NotesXMissingId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[NotesXMissing]
  ADD CONSTRAINT [FK_NotesXMissing_CreatedBy] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[NotesXMissing]
  ADD CONSTRAINT [FK_NotesXMissing_UserId] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([UserId])
GO