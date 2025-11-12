CREATE TABLE [dbo].[Groups] (
  [GroupId] [int] IDENTITY,
  [Name] [varchar](100) NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [CreatedOn] [datetime] NOT NULL,
  CONSTRAINT [PK_Groups] PRIMARY KEY CLUSTERED ([GroupId])
)
ON [PRIMARY]
GO

CREATE UNIQUE INDEX [IX_DataNonRepeatName]
  ON [dbo].[Groups] ([Name])
  ON [PRIMARY]
GO