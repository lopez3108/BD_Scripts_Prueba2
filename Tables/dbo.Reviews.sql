CREATE TABLE [dbo].[Reviews] (
  [ReviewId] [int] IDENTITY,
  [CreationDate] [datetime] NOT NULL,
  [ReviewName] [varchar](170) NOT NULL,
  [Status] [int] NOT NULL,
  [CycleDate] [datetime] NULL,
  [DaysToCompleteStatusId] [int] NULL,
  [DocumentName] [varchar](600) NULL,
  [CreatedBy] [int] NULL,
  [LastUpdatedOn] [datetime] NULL,
  [LastUpdatedBy] [int] NULL,
  [IsExternalReview] [bit] NULL,
  [ExpirationDateExternal] [date] NULL,
  CONSTRAINT [PK_Reviews] PRIMARY KEY CLUSTERED ([ReviewId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[Reviews]
  ADD CONSTRAINT [FK_Reviews_CreatedBy] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[Reviews]
  ADD CONSTRAINT [FK_Reviews_DaysToCompleteStatusId] FOREIGN KEY ([DaysToCompleteStatusId]) REFERENCES [dbo].[ReviewDaysStatus] ([DaysToCompleteStatusId])
GO