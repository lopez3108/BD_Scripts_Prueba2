CREATE TABLE [dbo].[TimeSheetStatus] (
  [Id] [int] IDENTITY,
  [Code] [varchar](3) NOT NULL,
  [Description] [varchar](20) NOT NULL,
  CONSTRAINT [PK_TimeSheetStatus] PRIMARY KEY CLUSTERED ([Id])
)
ON [PRIMARY]
GO