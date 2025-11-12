CREATE TABLE [dbo].[PropertiesBillWater] (
  [PropertiesBillWaterId] [int] IDENTITY,
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
  [Gallons] [decimal](18, 2) NOT NULL,
  [CurrentWater] [decimal](18, 2) NULL,
  [CurrentSewer] [decimal](18, 2) NULL,
  [CurrentWaterSewerTax] [decimal](18, 2) NULL,
  [CurrentGarbage] [decimal](18, 2) NULL,
  [CurrentPenalty] [decimal](18, 2) NULL,
  [WaterInvoice] [varchar](1000) NULL,
  [WaterPaid] [varchar](1000) NULL,
  [BillNumberSaved] [varchar](20) NULL,
  PRIMARY KEY CLUSTERED ([PropertiesBillWaterId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[PropertiesBillWater]
  ADD CONSTRAINT [FK_PropertiesBillWater_CardBanks] FOREIGN KEY ([CardBankId]) REFERENCES [dbo].[CardBanks] ([CardBankId])
GO

ALTER TABLE [dbo].[PropertiesBillWater]
  ADD CONSTRAINT [FK_PropertiesBillWater_ProviderCommissionPaymentTypes] FOREIGN KEY ([ProviderCommissionPaymentTypeId]) REFERENCES [dbo].[ProviderCommissionPaymentTypes] ([ProviderCommissionPaymentTypeId])
GO

ALTER TABLE [dbo].[PropertiesBillWater]
  ADD CONSTRAINT [FK_PropertiesBillWater_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[PropertiesBillWater]
  ADD CONSTRAINT [FKPropertiesBillWater_Properties] FOREIGN KEY ([PropertiesId]) REFERENCES [dbo].[Properties] ([PropertiesId])
GO