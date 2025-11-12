CREATE TABLE [dbo].[NotaryNotes] (
  [NotesXNotaryId] [int] IDENTITY,
  [NotaryId] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [ValidatedBy] [int] NOT NULL,
  [Note] [varchar](400) NOT NULL,
  [AgencyId] [int] NOT NULL,
  CONSTRAINT [PK_NotaryNotes] PRIMARY KEY CLUSTERED ([NotesXNotaryId])
)
ON [PRIMARY]
GO