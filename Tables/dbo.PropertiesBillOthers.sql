CREATE TABLE [dbo].[PropertiesBillOthers] (
  [PropertiesBillOtherId] [int] IDENTITY,
  [PropertiesId] [int] NOT NULL,
  [ApartmentId] [int] NULL,
  [Description] [varchar](250) NOT NULL,
  [IsCredit] [bit] NOT NULL,
  [ProviderCommissionPaymentTypeId] [int] NOT NULL,
  [Date] [datetime] NOT NULL,
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
  [OtherInvoice] [varchar](1000) NULL,
  PRIMARY KEY CLUSTERED ([PropertiesBillOtherId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[PropertiesBillOthers]
  ADD CONSTRAINT [FK_PropertiesBillOthers_BankAccounts] FOREIGN KEY ([BankAccountId]) REFERENCES [dbo].[BankAccounts] ([BankAccountId])
GO

ALTER TABLE [dbo].[PropertiesBillOthers]
  ADD CONSTRAINT [FK_PropertiesBillOthers_CardBanks] FOREIGN KEY ([CardBankId]) REFERENCES [dbo].[CardBanks] ([CardBankId])
GO

ALTER TABLE [dbo].[PropertiesBillOthers]
  ADD CONSTRAINT [FK_PropertiesBillOthers_ProviderCommissionPaymentTypes] FOREIGN KEY ([ProviderCommissionPaymentTypeId]) REFERENCES [dbo].[ProviderCommissionPaymentTypes] ([ProviderCommissionPaymentTypeId])
GO

ALTER TABLE [dbo].[PropertiesBillOthers]
  ADD CONSTRAINT [FK_PropertiesBillOthers_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[PropertiesBillOthers]
  ADD CONSTRAINT [FKPropertiesBillOthers_Properties] FOREIGN KEY ([PropertiesId]) REFERENCES [dbo].[Properties] ([PropertiesId])
GO