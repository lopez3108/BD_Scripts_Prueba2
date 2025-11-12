CREATE TABLE [dbo].[InsurancePolicy] (
  [InsurancePolicyId] [int] IDENTITY,
  [InsuranceQuoteId] [int] NULL,
  [ProviderId] [int] NOT NULL,
  [InsuranceCompaniesId] [int] NOT NULL,
  [ClientName] [varchar](70) NOT NULL,
  [ClientTelephone] [varchar](10) NOT NULL,
  [ExpirationDate] [datetime] NOT NULL,
  [PolicyNumber] [varchar](20) NOT NULL,
  [USD] [decimal](18, 2) NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [LastUpdatedOn] [datetime] NOT NULL,
  [LastUpdatedBy] [int] NOT NULL,
  [CreatedInAgencyId] [int] NOT NULL,
  [PolicyTypeId] [int] NOT NULL,
  [Cash] [decimal](18, 2) NULL,
  [PaymentStatusId] [int] NOT NULL,
  [CommissionStatusId] [int] NOT NULL,
  [ValidatedOn] [datetime] NULL,
  [ValidatedBy] [int] NULL,
  [ValidatedAgencyId] [int] NULL,
  [ValidatedUSD] [decimal](18, 2) NULL,
  [InsurancePaymentTypeId] [int] NULL,
  [ExpenseId] [int] NULL,
  [CashierCommission] [decimal](18, 2) NULL,
  [TelIsCheck] [bit] NULL,
  [CreatedByMonthlyPayment] [bit] NULL CONSTRAINT [DF__Insurance__Creat__0FEEBCE2] DEFAULT (0),
  [PaymentType] [varchar](50) NULL,
  [CardFee] [decimal](18, 2) NULL CONSTRAINT [DF__Insurance__CardF__314FB0AD] DEFAULT (0),
  [TransactionId] [varchar](36) NULL,
  [MonthlyPaymentUsd] [decimal](18, 2) NULL,
  [FeeService] [decimal](18, 2) NOT NULL CONSTRAINT [DF__Insurance__FeeSe__5A51C640] DEFAULT (0),
  [CommissionUsd] [decimal](18, 2) NOT NULL CONSTRAINT [DF__Insurance__Commi__5B45EA79] DEFAULT (0),
  [DOB] [datetime] NULL,
  CONSTRAINT [PK__Insuranc__8D74AD1F48794CDB] PRIMARY KEY CLUSTERED ([InsurancePolicyId])
)
ON [PRIMARY]
GO

CREATE UNIQUE INDEX [IDX_InsurancePolicy_Number_Company]
  ON [dbo].[InsurancePolicy] ([InsuranceCompaniesId], [PolicyNumber])
  ON [PRIMARY]
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE UNIQUE INDEX [IX_TransactionId_Index]
  ON [dbo].[InsurancePolicy] ([TransactionId])
  WHERE ([TransactionId] IS NOT NULL)
  ON [PRIMARY]
GO

ALTER TABLE [dbo].[InsurancePolicy]
  ADD CONSTRAINT [FK__Insurance__Insur__6133CDF9] FOREIGN KEY ([InsurancePaymentTypeId]) REFERENCES [dbo].[InsurancePaymentType] ([InsurancePaymentTypeId])
GO

ALTER TABLE [dbo].[InsurancePolicy]
  ADD CONSTRAINT [FK__Insurance__Valid__53D9D2DB] FOREIGN KEY ([ValidatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[InsurancePolicy]
  ADD CONSTRAINT [FK__Insurance__Valid__54CDF714] FOREIGN KEY ([ValidatedAgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[InsurancePolicy]
  ADD CONSTRAINT [FK_InsurancePolicy_InsuranceQuote] FOREIGN KEY ([InsuranceQuoteId]) REFERENCES [dbo].[InsuranceQuote] ([InsuranceQuoteId])
GO

ALTER TABLE [dbo].[InsurancePolicy]
  ADD CONSTRAINT [InsurancePolicy_CommissionStatusId_FK] FOREIGN KEY ([CommissionStatusId]) REFERENCES [dbo].[InsurancePolicyStatus] ([InsurancePolicyStatusId])
GO

ALTER TABLE [dbo].[InsurancePolicy]
  ADD CONSTRAINT [InsurancePolicy_CreatedBy_FK] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[InsurancePolicy]
  ADD CONSTRAINT [InsurancePolicy_CreatedInAgencyId_FK] FOREIGN KEY ([CreatedInAgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[InsurancePolicy]
  ADD CONSTRAINT [InsurancePolicy_InsuranceCompaniesId_FK] FOREIGN KEY ([InsuranceCompaniesId]) REFERENCES [dbo].[InsuranceCompanies] ([InsuranceCompaniesId])
GO

ALTER TABLE [dbo].[InsurancePolicy]
  ADD CONSTRAINT [InsurancePolicy_LastUpdatedBy_FK] FOREIGN KEY ([LastUpdatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[InsurancePolicy]
  ADD CONSTRAINT [InsurancePolicy_PaymentStatusId_FK] FOREIGN KEY ([PaymentStatusId]) REFERENCES [dbo].[InsurancePolicyStatus] ([InsurancePolicyStatusId])
GO

ALTER TABLE [dbo].[InsurancePolicy]
  ADD CONSTRAINT [InsurancePolicy_PolicyTypeId_FK] FOREIGN KEY ([PolicyTypeId]) REFERENCES [dbo].[PolicyType] ([PolicyTypeId])
GO

ALTER TABLE [dbo].[InsurancePolicy]
  ADD CONSTRAINT [InsurancePolicy_ProviderId_FK] FOREIGN KEY ([ProviderId]) REFERENCES [dbo].[Providers] ([ProviderId])
GO