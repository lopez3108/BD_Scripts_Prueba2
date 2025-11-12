CREATE TABLE [dbo].[FraudNotes] (
  [FraudNotesId] [int] IDENTITY,
  [FraudId] [int] NULL,
  [Note] [varchar](300) NULL,
  [CreationDate] [datetime] NULL,
  [CreatedBy] [int] NULL,
  CONSTRAINT [PK_FraudNotes_FraudNotesId] PRIMARY KEY CLUSTERED ([FraudNotesId])
)
ON [PRIMARY]
GO