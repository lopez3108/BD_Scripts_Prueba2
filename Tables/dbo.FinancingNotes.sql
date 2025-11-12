CREATE TABLE [dbo].[FinancingNotes] (
  [FinancingNoteId] [int] IDENTITY,
  [FinancingId] [int] NOT NULL,
  [Note] [varchar](300) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  CONSTRAINT [PK_FinancingNotes] PRIMARY KEY CLUSTERED ([FinancingNoteId])
)
ON [PRIMARY]
GO