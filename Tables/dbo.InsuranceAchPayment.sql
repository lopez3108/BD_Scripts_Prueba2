CREATE TABLE [dbo].[InsuranceAchPayment] (
  [InsuranceAchPaymentId] [int] IDENTITY,
  [BankAccountId] [int] NOT NULL,
  [AchDate] [datetime] NOT NULL,
  [USD] [decimal](18, 2) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [InsurancePolicyId] [int] NULL,
  [InsuranceMonthlyPaymentId] [int] NULL,
  [InsuranceRegistrationId] [int] NULL,
  [LastUpdatedBy] [int] NULL,
  [LastUpdatedOn] [datetime] NULL,
  [TypeId] [int] NOT NULL DEFAULT (1),
  PRIMARY KEY CLUSTERED ([InsuranceAchPaymentId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[InsuranceAchPayment]
  ADD CONSTRAINT [FK__Insurance__Insur__65F88316] FOREIGN KEY ([InsurancePolicyId]) REFERENCES [dbo].[InsurancePolicy] ([InsurancePolicyId])
GO

ALTER TABLE [dbo].[InsuranceAchPayment]
  ADD FOREIGN KEY ([InsuranceMonthlyPaymentId]) REFERENCES [dbo].[InsuranceMonthlyPayment] ([InsuranceMonthlyPaymentId])
GO

ALTER TABLE [dbo].[InsuranceAchPayment]
  ADD FOREIGN KEY ([InsuranceRegistrationId]) REFERENCES [dbo].[InsuranceRegistration] ([InsuranceRegistrationId])
GO