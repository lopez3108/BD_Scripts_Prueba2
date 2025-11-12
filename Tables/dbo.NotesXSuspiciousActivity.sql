CREATE TABLE [dbo].[NotesXSuspiciousActivity] (
  [NotesXSuspiciousActivityId] [int] IDENTITY,
  [SuspiciousActivityId] [int] NOT NULL,
  [Note] [varchar](300) NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  PRIMARY KEY CLUSTERED ([NotesXSuspiciousActivityId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[NotesXSuspiciousActivity]
  ADD CONSTRAINT [FK_NotesXSuspiciousActivity_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO