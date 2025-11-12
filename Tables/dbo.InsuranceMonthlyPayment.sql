CREATE TABLE [dbo].[InsuranceMonthlyPayment] (
  [InsuranceMonthlyPaymentId] [int] IDENTITY,
  [USD] [decimal](18, 2) NOT NULL,
  [MonthlyPaymentServiceFee] [decimal](18, 2) NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [LastUpdatedOn] [datetime] NOT NULL,
  [LastUpdatedBy] [int] NOT NULL,
  [Cash] [decimal](18, 2) NULL,
  [PaymentStatusId] [int] NOT NULL,
  [CommissionStatusId] [int] NOT NULL,
  [CardFee] [decimal](18, 2) NULL,
  [ValidatedOn] [datetime] NULL,
  [ValidatedBy] [int] NULL,
  [ValidatedAgencyId] [int] NULL,
  [ValidatedUSD] [decimal](18, 2) NULL,
  [InsurancePaymentTypeId] [int] NULL,
  [ExpenseId] [int] NULL,
  [CashierCommission] [decimal](18, 2) NULL,
  [TelIsCheck] [bit] NULL,
  [InsurancePolicyId] [int] NOT NULL,
  [CreatedInAgencyId] [int] NULL,
  [CreatedInsurancePolicyId] [int] NULL,
  [PaymentType] [varchar](50) NULL,
  [TransactionId] [varchar](36) NULL,
  [MonthlyPaymentStatusId] [int] NULL,
  [InsuranceCommissionTypeId] [int] NOT NULL DEFAULT (4),
  [CommissionUsd] [decimal](18, 2) NOT NULL DEFAULT (0),
  PRIMARY KEY CLUSTERED ([InsuranceMonthlyPaymentId])
)
ON [PRIMARY]
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE UNIQUE INDEX [idx_unique_transaction_payments]
  ON [dbo].[InsuranceMonthlyPayment] ([TransactionId])
  INCLUDE ([CreatedInsurancePolicyId])
  WHERE ([TransactionId] IS NOT NULL)
  ON [PRIMARY]
GO

ALTER TABLE [dbo].[InsuranceMonthlyPayment]
  ADD FOREIGN KEY ([CreatedInAgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[InsuranceMonthlyPayment]
  ADD CONSTRAINT [FK__Insurance__Creat__0E067470] FOREIGN KEY ([CreatedInsurancePolicyId]) REFERENCES [dbo].[InsurancePolicy] ([InsurancePolicyId])
GO

ALTER TABLE [dbo].[InsuranceMonthlyPayment]
  ADD CONSTRAINT [FK__Insurance__Insur__11D70554] FOREIGN KEY ([InsurancePolicyId]) REFERENCES [dbo].[InsurancePolicy] ([InsurancePolicyId])
GO

ALTER TABLE [dbo].[InsuranceMonthlyPayment]
  ADD FOREIGN KEY ([InsurancePaymentTypeId]) REFERENCES [dbo].[InsurancePaymentType] ([InsurancePaymentTypeId])
GO

ALTER TABLE [dbo].[InsuranceMonthlyPayment]
  ADD FOREIGN KEY ([ValidatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[InsuranceMonthlyPayment]
  ADD FOREIGN KEY ([ValidatedAgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[InsuranceMonthlyPayment]
  ADD CONSTRAINT [FK_InsuranceMonthlyPayment_InsuranceCommissionTypeId] FOREIGN KEY ([InsuranceCommissionTypeId]) REFERENCES [dbo].[InsuranceCommissionType] ([InsuranceCommissionTypeId])
GO

ALTER TABLE [dbo].[InsuranceMonthlyPayment]
  ADD CONSTRAINT [FK_InsuranceMonthlyPayment_MonthlyPaymentStatus] FOREIGN KEY ([MonthlyPaymentStatusId]) REFERENCES [dbo].[MonthlyPaymentStatus] ([MonthlyPaymentStatusId])
GO

ALTER TABLE [dbo].[InsuranceMonthlyPayment]
  ADD CONSTRAINT [InsuranceMonthlyPayment_CommissionStatusId_FK] FOREIGN KEY ([CommissionStatusId]) REFERENCES [dbo].[InsurancePolicyStatus] ([InsurancePolicyStatusId])
GO

ALTER TABLE [dbo].[InsuranceMonthlyPayment]
  ADD CONSTRAINT [InsuranceMonthlyPayment_CreatedBy_FK] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[InsuranceMonthlyPayment]
  ADD CONSTRAINT [InsuranceMonthlyPayment_LastUpdatedBy_FK] FOREIGN KEY ([LastUpdatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[InsuranceMonthlyPayment]
  ADD CONSTRAINT [InsuranceMonthlyPayment_PaymentStatusId_FK] FOREIGN KEY ([PaymentStatusId]) REFERENCES [dbo].[InsurancePolicyStatus] ([InsurancePolicyStatusId])
GO