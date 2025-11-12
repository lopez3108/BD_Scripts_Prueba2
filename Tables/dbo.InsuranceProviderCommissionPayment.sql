CREATE TABLE [dbo].[InsuranceProviderCommissionPayment] (
  [InsuranceProviderCommissionPaymentId] [int] IDENTITY,
  [ProviderCommissionPaymentId] [int] NOT NULL,
  [NewPolicyQuantity] [int] NOT NULL,
  [NewPolicyAmount] [decimal](18, 2) NOT NULL,
  [MonthlyPaymentQuantity] [int] NOT NULL,
  [MonthlyPaymentAmount] [decimal](18, 2) NOT NULL,
  [EndorsementQuantity] [int] NOT NULL,
  [EndorsementAmount] [decimal](18, 2) NOT NULL,
  [PolicyRenewalQuantity] [int] NOT NULL,
  [PolicyRenewalAmount] [decimal](18, 2) NOT NULL,
  [RegistrationReleaseQuantity] [int] NOT NULL,
  [RegistrationReleaseAmount] [decimal](18, 2) NOT NULL,
  CONSTRAINT [PK_InsuranceProviderCommissionPayment] PRIMARY KEY CLUSTERED ([InsuranceProviderCommissionPaymentId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[InsuranceProviderCommissionPayment]
  ADD CONSTRAINT [FK_InsuranceProviderCommissionPayment_ProviderCommissionPayments] FOREIGN KEY ([ProviderCommissionPaymentId]) REFERENCES [dbo].[ProviderCommissionPayments] ([ProviderCommissionPaymentId])
GO