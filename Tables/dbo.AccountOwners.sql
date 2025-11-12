CREATE TABLE [dbo].[AccountOwners] (
  [AccountOwnerId] [int] IDENTITY,
  [Name] [varchar](50) NOT NULL,
  [Code] AS ('C'+CONVERT([varchar](6),[AccountOwnerId])),
  [Active] [bit] NOT NULL DEFAULT (1),
  PRIMARY KEY CLUSTERED ([AccountOwnerId])
)
ON [PRIMARY]
GO