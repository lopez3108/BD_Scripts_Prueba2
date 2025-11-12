CREATE TABLE [dbo].[ProvisionalNote] (
  [ProvisionalNotesId] [int] IDENTITY,
  [ProvisionalReceiptId] [int] NULL,
  [Note] [nchar](300) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  CONSTRAINT [PK_ProvisionalNote] PRIMARY KEY CLUSTERED ([ProvisionalNotesId])
)
ON [PRIMARY]
GO