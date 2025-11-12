CREATE TABLE [dbo].[ReminderAgenda] (
  [ReminderAgendaId] [int] IDENTITY,
  [Monday] [bit] NULL,
  [Tuesday] [bit] NULL,
  [Wednesday] [bit] NULL,
  [Thursday] [bit] NULL,
  [Friday] [bit] NULL,
  [Saturday] [bit] NULL,
  [Sunday] [bit] NULL,
  [FromDate] [date] NULL,
  [ToDate] [date] NULL,
  [AgendaId] [int] NOT NULL,
  [ShowReminder] [bit] NULL,
  CONSTRAINT [PK_ReminderAgenda_ReminderAgendaId] PRIMARY KEY CLUSTERED ([ReminderAgendaId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[ReminderAgenda]
  ADD CONSTRAINT [FK_ReminderAgenda_AgendaId] FOREIGN KEY ([AgendaId]) REFERENCES [dbo].[Agendas] ([AgendaId])
GO