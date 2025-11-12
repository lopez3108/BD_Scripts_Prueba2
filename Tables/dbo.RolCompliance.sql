CREATE TABLE [dbo].[RolCompliance] (
  [RolComplianceId] [int] IDENTITY,
  [RolName] [varchar](50) NOT NULL,
  [Code] [varchar](3) NOT NULL,
  CONSTRAINT [PK_RolCompliance] PRIMARY KEY CLUSTERED ([RolComplianceId])
)
ON [PRIMARY]
GO