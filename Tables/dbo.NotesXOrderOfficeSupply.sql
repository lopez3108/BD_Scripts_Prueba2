CREATE TABLE [dbo].[NotesXOrderOfficeSupply] (
  [NoteXOrderSupplyId] [int] IDENTITY,
  [Note] [varchar](150) NULL,
  [OrderOfficeSupplieId] [int] NULL,
  [CreationDate] [datetime] NULL,
  [CreatedBy] [int] NULL,
  CONSTRAINT [PK_NotesXOrderOfficeSupply] PRIMARY KEY CLUSTERED ([NoteXOrderSupplyId])
)
ON [PRIMARY]
GO