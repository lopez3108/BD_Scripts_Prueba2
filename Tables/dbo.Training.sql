CREATE TABLE [dbo].[Training] (
  [TrainingId] [int] IDENTITY,
  [CreationDate] [datetime] NOT NULL,
  [TrainingName] [varchar](170) NOT NULL,
  [Status] [int] NOT NULL,
  [IsRequired] [bit] NOT NULL,
  [CycleDate] [datetime] NOT NULL,
  [DaysToCompleteStatusId] [int] NOT NULL,
  [DocumentName] [varchar](600) NULL,
  [CreatedBy] [int] NULL,
  [LastUpdatedOn] [datetime] NULL,
  [LastUpdatedBy] [int] NULL,
  [ApplyToAdmin] [bit] NULL CONSTRAINT [DF_Training_ApplyToAdmin] DEFAULT (0),
  [ApplyToCashier] [bit] NULL CONSTRAINT [DF_Training_ApplyToCashier] DEFAULT (0),
  [ApplyToManager] [bit] NULL CONSTRAINT [DF_Training_ApplyToManager] DEFAULT (0),
  CONSTRAINT [PK_Training] PRIMARY KEY CLUSTERED ([TrainingId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[Training]
  ADD CONSTRAINT [FK_Training_CreatedBy] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[Training]
  ADD CONSTRAINT [FK_Training_DaysToCompleteStatusId] FOREIGN KEY ([DaysToCompleteStatusId]) REFERENCES [dbo].[TrainingDaysStatus] ([DaysToCompleteStatusId])
GO