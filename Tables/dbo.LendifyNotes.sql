CREATE TABLE [dbo].[LendifyNotes] (
  [LendifyNotesId] [int] IDENTITY,
  [LendifyId] [int] NOT NULL,
  [Note] [varchar](300) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  CONSTRAINT [PK_LendifyNotes] PRIMARY KEY CLUSTERED ([LendifyNotesId])
)
ON [PRIMARY]
GO