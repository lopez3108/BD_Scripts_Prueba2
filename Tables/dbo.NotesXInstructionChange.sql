CREATE TABLE [dbo].[NotesXInstructionChange] (
  [NoteXInstructionId] [int] IDENTITY,
  [CreatedBy] [int] NULL,
  [CreationDate] [datetime] NULL,
  [Note] [varchar](400) NULL,
  [InstructionChangeId] [int] NULL,
  CONSTRAINT [PK_NotesXInstructionChange] PRIMARY KEY CLUSTERED ([NoteXInstructionId])
)
ON [PRIMARY]
GO