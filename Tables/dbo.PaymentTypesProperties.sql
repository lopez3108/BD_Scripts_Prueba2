CREATE TABLE [dbo].[PaymentTypesProperties] (
  [PaymentTypePropertiesId] [int] IDENTITY,
  [Code] [varchar](3) NULL,
  [Description] [varchar](20) NULL,
  CONSTRAINT [PK_PaymentTypesProperties_PaymentTypePropertiesId] PRIMARY KEY CLUSTERED ([PaymentTypePropertiesId])
)
ON [PRIMARY]
GO