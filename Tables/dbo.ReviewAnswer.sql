CREATE TABLE [dbo].[ReviewAnswer] (
  [ReviewAnswerId] [int] IDENTITY,
  [ReviewQuestionsId] [int] NOT NULL,
  [Answer] [bit] NULL CONSTRAINT [DF_ReviewAnswer_Answer] DEFAULT (0),
  [MultipleAnswer] [varchar](5) NULL,
  [Explain] [varchar](450) NULL,
  [UserId] [int] NULL,
  CONSTRAINT [PK_ReviewAnswer] PRIMARY KEY CLUSTERED ([ReviewAnswerId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[ReviewAnswer]
  ADD CONSTRAINT [FK_ReviewAnswer_ReviewQuestions] FOREIGN KEY ([ReviewQuestionsId]) REFERENCES [dbo].[ReviewQuestions] ([ReviewQuestionsId])
GO

ALTER TABLE [dbo].[ReviewAnswer]
  ADD CONSTRAINT [FK_ReviewAnswer_UserId] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([UserId])
GO