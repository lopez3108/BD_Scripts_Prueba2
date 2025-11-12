CREATE TABLE [dbo].[ProviderServicesXProviders] (
  [ProviderServiceXProviderId] [int] IDENTITY,
  [ProviderId] [int] NOT NULL,
  [ProviderServiceId] [int] NOT NULL,
  CONSTRAINT [PK_ProviderServicesXProviders_ProviderServiceXProvider] PRIMARY KEY CLUSTERED ([ProviderServiceXProviderId])
)
ON [PRIMARY]
GO