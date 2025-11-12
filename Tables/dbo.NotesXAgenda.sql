CREATE TABLE [dbo].[NotesXAgenda] (
  [NoteXAgendaId] [int] IDENTITY,
  [CreatedBy] [int] NOT NULL,
  [Note] [varchar](400) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [AgendaId] [int] NOT NULL,
  CONSTRAINT [PK_NotesXAgenda_NoteXAgendaId] PRIMARY KEY CLUSTERED ([NoteXAgendaId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[NotesXAgenda]
  ADD CONSTRAINT [FK_NotesXAgenda_AgendaId] FOREIGN KEY ([AgendaId]) REFERENCES [dbo].[Agendas] ([AgendaId])
GO