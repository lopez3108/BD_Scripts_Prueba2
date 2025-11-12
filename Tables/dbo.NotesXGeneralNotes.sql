CREATE TABLE [dbo].[NotesXGeneralNotes] (
  [NotesXGeneralNoteId] [int] IDENTITY,
  [GeneralNoteId] [int] NOT NULL,
  [Description] [varchar](2000) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [AgencyId] [int] NOT NULL,
  CONSTRAINT [PK_NotesXGeneralNotes] PRIMARY KEY CLUSTERED ([NotesXGeneralNoteId])
)
ON [PRIMARY]
GO