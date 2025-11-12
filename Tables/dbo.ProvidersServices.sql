CREATE TABLE [dbo].[ProvidersServices] (
  [ProviderServiceId] [int] IDENTITY,
  [Description] [varchar](60) NULL,
  [Code] [varchar](3) NULL,
  [Translate] [varchar](50) NULL,
  CONSTRAINT [PK_ProvidersServices_ProviderServiceId] PRIMARY KEY CLUSTERED ([ProviderServiceId])
)
ON [PRIMARY]
GO