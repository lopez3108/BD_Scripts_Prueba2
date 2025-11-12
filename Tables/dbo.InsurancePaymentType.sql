CREATE TABLE [dbo].[InsurancePaymentType] (
  [InsurancePaymentTypeId] [int] IDENTITY,
  [Code] [varchar](5) NOT NULL,
  [Description] [varchar](20) NOT NULL,
  PRIMARY KEY CLUSTERED ([InsurancePaymentTypeId])
)
ON [PRIMARY]
GO