CREATE TABLE [dbo].[PropertiesBillLabor] (
  [PropertiesBillLaborId] [int] IDENTITY,
  [PropertiesId] [int] NOT NULL,
  [ApartmentId] [int] NULL,
  [Name] [varchar](50) NOT NULL,
  [Note] [varchar](300) NOT NULL,
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
  [ContractId] [int] NULL,
  [DepositUsed] [decimal](18, 2) NULL,
  [LaborInvoice] [varchar](1000) NULL,
  PRIMARY KEY CLUSTERED ([PropertiesBillLaborId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[PropertiesBillLabor]
  ADD CONSTRAINT [FK_PropertiesBillLabor_BankAccounts] FOREIGN KEY ([BankAccountId]) REFERENCES [dbo].[BankAccounts] ([BankAccountId])
GO

ALTER TABLE [dbo].[PropertiesBillLabor]
  ADD CONSTRAINT [FK_PropertiesBillLabor_CardBanks] FOREIGN KEY ([CardBankId]) REFERENCES [dbo].[CardBanks] ([CardBankId])
GO

ALTER TABLE [dbo].[PropertiesBillLabor]
  ADD CONSTRAINT [FK_PropertiesBillLabor_ProviderCommissionPaymentTypes] FOREIGN KEY ([ProviderCommissionPaymentTypeId]) REFERENCES [dbo].[ProviderCommissionPaymentTypes] ([ProviderCommissionPaymentTypeId])
GO

ALTER TABLE [dbo].[PropertiesBillLabor]
  ADD CONSTRAINT [FK_PropertiesBillLabor_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[PropertiesBillLabor]
  ADD CONSTRAINT [FKPropertiesBillLabor_Properties] FOREIGN KEY ([PropertiesId]) REFERENCES [dbo].[Properties] ([PropertiesId])
GO