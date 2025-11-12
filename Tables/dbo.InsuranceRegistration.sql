CREATE TABLE [dbo].[InsuranceRegistration] (
  [InsuranceRegistrationId] [int] IDENTITY,
  [ProviderId] [int] NOT NULL,
  [ClientName] [varchar](70) NOT NULL,
  [ClientTelephone] [varchar](10) NOT NULL,
  [USD] [decimal](18, 2) NOT NULL,
  [RegistrationReleaseSOSFee] [decimal](18, 2) NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [LastUpdatedOn] [datetime] NOT NULL,
  [LastUpdatedBy] [int] NOT NULL,
  [CreatedInAgencyId] [int] NOT NULL,
  [Cash] [decimal](18, 2) NULL,
  [PaymentStatusId] [int] NOT NULL,
  [CommissionStatusId] [int] NOT NULL,
  [CardFee] [decimal](18, 2) NULL,
  [ValidatedOn] [datetime] NULL,
  [ValidatedBy] [int] NULL,
  [ValidatedAgencyId] [int] NULL,
  [ValidatedUSD] [decimal](18, 2) NULL,
  [InsurancePaymentTypeId] [int] NULL,
  [CashierCommission] [decimal](18, 2) NULL,
  [ExpenseId] [int] NULL,
  [TelIsCheck] [bit] NULL,
  [PaymentType] [varchar](50) NULL,
  PRIMARY KEY CLUSTERED ([InsuranceRegistrationId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[InsuranceRegistration]
  ADD FOREIGN KEY ([InsurancePaymentTypeId]) REFERENCES [dbo].[InsurancePaymentType] ([InsurancePaymentTypeId])
GO

ALTER TABLE [dbo].[InsuranceRegistration]
  ADD FOREIGN KEY ([ValidatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[InsuranceRegistration]
  ADD FOREIGN KEY ([ValidatedAgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[InsuranceRegistration]
  ADD CONSTRAINT [InsuranceRegistration_CommissionStatusId_FK] FOREIGN KEY ([CommissionStatusId]) REFERENCES [dbo].[InsurancePolicyStatus] ([InsurancePolicyStatusId])
GO

ALTER TABLE [dbo].[InsuranceRegistration]
  ADD CONSTRAINT [InsuranceRegistration_CreatedBy_FK] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[InsuranceRegistration]
  ADD CONSTRAINT [InsuranceRegistration_CreatedInAgencyId_FK] FOREIGN KEY ([CreatedInAgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[InsuranceRegistration]
  ADD CONSTRAINT [InsuranceRegistration_LastUpdatedBy_FK] FOREIGN KEY ([LastUpdatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[InsuranceRegistration]
  ADD CONSTRAINT [InsuranceRegistration_PaymentStatusId_FK] FOREIGN KEY ([PaymentStatusId]) REFERENCES [dbo].[InsurancePolicyStatus] ([InsurancePolicyStatusId])
GO

ALTER TABLE [dbo].[InsuranceRegistration]
  ADD CONSTRAINT [InsuranceRegistration_ProviderId_FK] FOREIGN KEY ([ProviderId]) REFERENCES [dbo].[Providers] ([ProviderId])
GO