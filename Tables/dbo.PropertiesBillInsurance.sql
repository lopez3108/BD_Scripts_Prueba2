CREATE TABLE [dbo].[PropertiesBillInsurance] (
  [PropertiesBillInsuranceId] [int] IDENTITY,
  [PropertiesId] [int] NOT NULL,
  [ProviderCommissionPaymentTypeId] [int] NOT NULL,
  [FromDate] [datetime] NOT NULL,
  [ToDate] [datetime] NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  [CheckNumber] [varchar](15) NULL,
  [CheckDate] [datetime] NULL,
  [BankAccountId] [int] NULL,
  [CardBankId] [int] NULL,
  [AgencyId] [int] NULL,
  [MoneyOrderNumber] [varchar](20) NULL,
  [AchDate] [datetime] NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [PolicyNumberSaved] [varchar](20) NULL,
  PRIMARY KEY CLUSTERED ([PropertiesBillInsuranceId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[PropertiesBillInsurance]
  ADD CONSTRAINT [FK_PropertiesBillInsurance_BankAccounts] FOREIGN KEY ([BankAccountId]) REFERENCES [dbo].[BankAccounts] ([BankAccountId])
GO

ALTER TABLE [dbo].[PropertiesBillInsurance] WITH NOCHECK
  ADD CONSTRAINT [FK_PropertiesBillInsurance_CardBanks] FOREIGN KEY ([CardBankId]) REFERENCES [dbo].[CardBanks] ([CardBankId])
GO

ALTER TABLE [dbo].[PropertiesBillInsurance]
  ADD CONSTRAINT [FK_PropertiesBillInsurance_ProviderCommissionTypeId] FOREIGN KEY ([ProviderCommissionPaymentTypeId]) REFERENCES [dbo].[ProviderCommissionPaymentTypes] ([ProviderCommissionPaymentTypeId])
GO

ALTER TABLE [dbo].[PropertiesBillInsurance]
  ADD CONSTRAINT [FK_PropertiesBillInsurance_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[PropertiesBillInsurance]
  ADD CONSTRAINT [FKPropertiesBillInsurance_Properties] FOREIGN KEY ([PropertiesId]) REFERENCES [dbo].[Properties] ([PropertiesId])
GO