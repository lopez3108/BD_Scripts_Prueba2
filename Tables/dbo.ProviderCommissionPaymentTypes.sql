CREATE TABLE [dbo].[ProviderCommissionPaymentTypes] (
  [ProviderCommissionPaymentTypeId] [int] IDENTITY,
  [Code] [varchar](20) NOT NULL,
  [Description] [varchar](50) NOT NULL,
  CONSTRAINT [PK_ProviderCommissionPaymentTypes] PRIMARY KEY CLUSTERED ([ProviderCommissionPaymentTypeId])
)
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Tabla precarga', 'SCHEMA', N'dbo', 'TABLE', N'ProviderCommissionPaymentTypes'
GO