CREATE TABLE [dbo].[OthersNotes] (
  [NotesXOthersId] [int] IDENTITY,
  [OtherDetailId] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [ValidatedBy] [int] NULL,
  [Note] [varchar](400) NOT NULL,
  [AgencyId] [int] NOT NULL,
  CONSTRAINT [PK_OthersNotes] PRIMARY KEY CLUSTERED ([NotesXOthersId])
)
ON [PRIMARY]
GO