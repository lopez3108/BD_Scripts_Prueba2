CREATE TABLE [dbo].[FinancingStatus] (
  [FinancingStatusId] [int] IDENTITY,
  [Description] [varchar](30) NOT NULL,
  [Code] [varchar](10) NOT NULL,
  [Color] [varchar](20) NULL,
  CONSTRAINT [PK_FinancingStatus] PRIMARY KEY CLUSTERED ([FinancingStatusId])
)
ON [PRIMARY]
GO