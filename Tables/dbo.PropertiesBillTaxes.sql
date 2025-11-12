CREATE TABLE [dbo].[PropertiesBillTaxes] (
  [PropertiesBillTaxesId] [int] IDENTITY,
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
  [TaxesInvoice] [varchar](1000) NULL,
  [TaxesPaid] [varchar](1000) NULL,
  PRIMARY KEY CLUSTERED ([PropertiesBillTaxesId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[PropertiesBillTaxes]
  ADD CONSTRAINT [FK_PropertiesBillTaxes_BankAccounts] FOREIGN KEY ([BankAccountId]) REFERENCES [dbo].[BankAccounts] ([BankAccountId])
GO

ALTER TABLE [dbo].[PropertiesBillTaxes]
  ADD CONSTRAINT [FK_PropertiesBillTaxes_CardBanks] FOREIGN KEY ([CardBankId]) REFERENCES [dbo].[CardBanks] ([CardBankId])
GO

ALTER TABLE [dbo].[PropertiesBillTaxes]
  ADD CONSTRAINT [FK_PropertiesBillTaxes_ProviderCommissionTypes] FOREIGN KEY ([ProviderCommissionPaymentTypeId]) REFERENCES [dbo].[ProviderCommissionPaymentTypes] ([ProviderCommissionPaymentTypeId])
GO

ALTER TABLE [dbo].[PropertiesBillTaxes]
  ADD CONSTRAINT [FK_PropertiesBillTaxes_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[PropertiesBillTaxes]
  ADD CONSTRAINT [FKPropertiesBillTaxes_Properties] FOREIGN KEY ([PropertiesId]) REFERENCES [dbo].[Properties] ([PropertiesId])
GO