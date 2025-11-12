CREATE TABLE [dbo].[NotesxCancellations] (
  [NoteXCancellationId] [int] IDENTITY,
  [Description] [varchar](300) NOT NULL,
  [CancellationId] [nchar](10) NULL,
  [CreationDate] [datetime] NULL,
  [CreatedBy] [int] NULL,
  [UpdatedOn] [datetime] NULL,
  [UpdatedBy] [int] NULL,
  CONSTRAINT [PK_NotesxCancellations] PRIMARY KEY CLUSTERED ([NoteXCancellationId]),
  CONSTRAINT [UQ__NotesxCa__4EBBBAC932F0E9ED] UNIQUE ([Description])
)
ON [PRIMARY]
GO