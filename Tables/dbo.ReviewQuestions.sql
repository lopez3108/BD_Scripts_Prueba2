CREATE TABLE [dbo].[ReviewQuestions] (
  [ReviewQuestionsId] [int] IDENTITY,
  [ReviewId] [int] NOT NULL,
  [Question] [nvarchar](3000) NOT NULL,
  [Answer] [bit] NULL CONSTRAINT [DF_ReviewQuestions_Answer] DEFAULT (0),
  [IsMultiple] [bit] NULL CONSTRAINT [DF_ReviewQuestions_IsMultiple] DEFAULT (0),
  [Option1] [varchar](300) NULL,
  [Option2] [varchar](300) NULL,
  [Option3] [varchar](300) NULL,
  [Option4] [varchar](300) NULL,
  [MultipleAnswer] [varchar](5) NULL,
  [IsExplanation] [bit] NULL CONSTRAINT [DF_ReviewQuestions_IsExplanation] DEFAULT (0),
  [Explain] [varchar](450) NULL,
  CONSTRAINT [PK_ReviewQuestions] PRIMARY KEY CLUSTERED ([ReviewQuestionsId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[ReviewQuestions]
  ADD CONSTRAINT [FK_ReviewQuestions_ReviewId] FOREIGN KEY ([ReviewId]) REFERENCES [dbo].[Reviews] ([ReviewId])
GO