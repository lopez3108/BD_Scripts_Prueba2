CREATE TABLE [dbo].[SuspiciousActivityStatus] (
  [SuspiciousActivityStatusId] [int] IDENTITY,
  [Description] [varchar](50) NOT NULL,
  PRIMARY KEY CLUSTERED ([SuspiciousActivityStatusId])
)
ON [PRIMARY]
GO