CREATE TABLE [dbo].[CommissionPaymentTypesXProviders] (
  [CommissionPaymentTypesXProviderId] [int] IDENTITY,
  [ProviderId] [int] NOT NULL,
  [ProviderCommissionPaymentTypeId] [int] NOT NULL,
  [IsCommissionForex] [bit] NULL DEFAULT (0)
)
ON [PRIMARY]
GO