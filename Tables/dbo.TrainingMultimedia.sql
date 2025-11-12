CREATE TABLE [dbo].[TrainingMultimedia] (
  [TrainingMultimediaId] [int] IDENTITY,
  [TrainingId] [int] NULL,
  [TrainingQuestionsId] [int] NULL,
  [DocumentNameMultimedia] [varchar](500) NOT NULL,
  [IsImage] [bit] NULL CONSTRAINT [DF_TrainingMultimedia_IsImage] DEFAULT (0)
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[TrainingMultimedia] WITH NOCHECK
  ADD CONSTRAINT [FK_TrainingMultimedia_Training] FOREIGN KEY ([TrainingId]) REFERENCES [dbo].[Training] ([TrainingId]) NOT FOR REPLICATION
GO

ALTER TABLE [dbo].[TrainingMultimedia] WITH NOCHECK
  ADD CONSTRAINT [FK_TrainingMultimedia_Training1] FOREIGN KEY ([TrainingQuestionsId]) REFERENCES [dbo].[TrainingQuestions] ([TrainingQuestionsId]) NOT FOR REPLICATION
GO