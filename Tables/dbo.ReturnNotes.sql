CREATE TABLE [dbo].[ReturnNotes] (
  [ReturnNotesId] [int] IDENTITY,
  [ReturnedCheckId] [int] NOT NULL,
  [Note] [varchar](500) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL
)
ON [PRIMARY]
GO