CREATE TABLE [dbo].[TrainingQuestions] (
  [TrainingQuestionsId] [int] IDENTITY,
  [TrainingId] [int] NOT NULL,
  [Question] [nvarchar](3000) NOT NULL,
  [Answer] [bit] NULL CONSTRAINT [DF_TrainingQuestions_Yes] DEFAULT (0),
  [IsMultiple] [bit] NULL CONSTRAINT [DF_TrainingQuestions_IsMultiple] DEFAULT (0),
  [Option1] [varchar](300) NULL,
  [Option2] [varchar](300) NULL,
  [Option3] [varchar](300) NULL,
  [Option4] [varchar](300) NULL,
  [MultipleAnswer] [varchar](5) NULL,
  CONSTRAINT [PK_TrainingQuestions] PRIMARY KEY CLUSTERED ([TrainingQuestionsId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[TrainingQuestions]
  ADD CONSTRAINT [FK_TrainingQuestions_Training] FOREIGN KEY ([TrainingId]) REFERENCES [dbo].[Training] ([TrainingId])
GO