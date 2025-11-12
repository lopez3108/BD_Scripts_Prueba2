CREATE TABLE [dbo].[CancellationNote] (
  [CancellationsNotesId] [int] IDENTITY,
  [CancellationId] [int] NULL,
  [Note] [varchar](300) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  CONSTRAINT [PK_CancellationNote] PRIMARY KEY CLUSTERED ([CancellationsNotesId])
)
ON [PRIMARY]
GO