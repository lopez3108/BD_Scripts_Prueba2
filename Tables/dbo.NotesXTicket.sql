CREATE TABLE [dbo].[NotesXTicket] (
  [NoteXTicketId] [int] IDENTITY,
  [CreatedBy] [int] NOT NULL,
  [Note] [varchar](400) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [TicketId] [int] NOT NULL,
  CONSTRAINT [PK_NotesXTicket] PRIMARY KEY CLUSTERED ([NoteXTicketId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[NotesXTicket]
  ADD CONSTRAINT [FK_NotesXTicket_Tickets] FOREIGN KEY ([TicketId]) REFERENCES [dbo].[Tickets] ([TicketId])
GO

ALTER TABLE [dbo].[NotesXTicket]
  ADD CONSTRAINT [FK_NotesXTicket_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO