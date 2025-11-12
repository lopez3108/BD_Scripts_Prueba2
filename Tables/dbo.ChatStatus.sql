CREATE TABLE [dbo].[ChatStatus] (
  [ChatStatusId] [int] IDENTITY,
  [Name] [varchar](30) NOT NULL,
  [Code] [varchar](5) NOT NULL,
  CONSTRAINT [PK_ChatStatus] PRIMARY KEY CLUSTERED ([ChatStatusId])
)
ON [PRIMARY]
GO