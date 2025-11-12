CREATE TABLE [dbo].[DailyAdjustments] (
  [DailyAdjustmentId] [int] IDENTITY,
  [DailyId] [int] NOT NULL,
  [InitalMissing] [decimal](18, 2) NOT NULL,
  [FinalMissing] [decimal](18, 2) NOT NULL,
  [DifferenceMissing] [decimal](18, 2) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  CONSTRAINT [PK_DailyAdjustments] PRIMARY KEY CLUSTERED ([DailyAdjustmentId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[DailyAdjustments]
  ADD CONSTRAINT [FK_DailyAdjustments_Daily] FOREIGN KEY ([DailyId]) REFERENCES [dbo].[Daily] ([DailyId])
GO

ALTER TABLE [dbo].[DailyAdjustments]
  ADD CONSTRAINT [FK_DailyAdjustments_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO