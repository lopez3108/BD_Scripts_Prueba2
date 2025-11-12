CREATE TABLE [dbo].[ProviderTypes] (
  [ProviderTypeId] [int] IDENTITY,
  [Code] [varchar](10) NULL,
  [Description] [varchar](30) NOT NULL,
  CONSTRAINT [PK_ProviderTypes] PRIMARY KEY CLUSTERED ([ProviderTypeId])
)
ON [PRIMARY]
GO