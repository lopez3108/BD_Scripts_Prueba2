CREATE TABLE [dbo].[TrainingDaysStatus] (
  [DaysToCompleteStatusId] [int] IDENTITY,
  [Code] [varchar](3) NOT NULL,
  [Description] [varchar](50) NOT NULL,
  CONSTRAINT [PK_TrainingDaysStatus] PRIMARY KEY CLUSTERED ([DaysToCompleteStatusId])
)
ON [PRIMARY]
GO