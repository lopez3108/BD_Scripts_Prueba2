CREATE TABLE [dbo].[PermitTypes] (
  [PermitTypeId] [int] IDENTITY,
  [Description] [varchar](50) NOT NULL,
  [Code] [varchar](10) NOT NULL,
  CONSTRAINT [PK_PermitTypes] PRIMARY KEY CLUSTERED ([PermitTypeId])
)
ON [PRIMARY]
GO