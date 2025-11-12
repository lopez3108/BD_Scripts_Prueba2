CREATE TABLE [dbo].[ReviewDaysStatus] (
  [DaysToCompleteStatusId] [int] IDENTITY,
  [Code] [varchar](3) NOT NULL,
  [Description] [varchar](50) NOT NULL,
  CONSTRAINT [PK_ReviewDaysStatus] PRIMARY KEY CLUSTERED ([DaysToCompleteStatusId])
)
ON [PRIMARY]
GO