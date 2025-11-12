CREATE TABLE [dbo].[LendifyStatus] (
  [LendifyStatusId] [int] IDENTITY,
  [Code] [varchar](4) NOT NULL,
  [Description] [varchar](20) NOT NULL,
  CONSTRAINT [PK_LendifyStatus] PRIMARY KEY CLUSTERED ([LendifyStatusId])
)
ON [PRIMARY]
GO