CREATE TABLE [dbo].[SuspiciousActivityNotes] (
  [SuspiciousActivityNoteId] [int] IDENTITY,
  [SuspiciousActivityId] [int] NOT NULL,
  [Note] [varchar](300) NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  PRIMARY KEY CLUSTERED ([SuspiciousActivityNoteId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[SuspiciousActivityNotes]
  ADD CONSTRAINT [FK_SuspiciousActivityNotes_SuspiciousActivity] FOREIGN KEY ([SuspiciousActivityId]) REFERENCES [dbo].[SuspiciousActivity] ([SuspiciousActivityId])
GO

ALTER TABLE [dbo].[SuspiciousActivityNotes]
  ADD CONSTRAINT [FK_SuspiciousActivityNotes_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO