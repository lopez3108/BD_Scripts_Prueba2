CREATE TABLE [dbo].[ConfigurationELS] (
  [ConfigurationELSId] [int] IDENTITY,
  [MoneyOrderFee] [decimal](18, 2) NOT NULL,
  [PhoneMaxDiscount] [decimal](18, 2) NOT NULL,
  [TitlePlatesDiscount] [decimal](18, 2) NOT NULL CONSTRAINT [DF_ConfigurationELS_TitlePlatesDiscount] DEFAULT (0),
  [FinancingCancelFee] [decimal](18, 2) NOT NULL CONSTRAINT [DF_ConfigurationELS_FinancingCancelFee] DEFAULT (0),
  [DaysToCashCheck] [decimal](18, 2) NOT NULL CONSTRAINT [DF_ConfigurationELS_FinancingCancelFee1] DEFAULT (0),
  [SalesTax] [decimal](18, 2) NOT NULL CONSTRAINT [DF_ConfigurationELS_DaysToCashCheck1] DEFAULT (0),
  [CheckRangeRegistering] [int] NOT NULL CONSTRAINT [DF_ConfigurationELS_CheckRangeRegistering] DEFAULT (0),
  [LaminationFee] [decimal](18, 2) NOT NULL CONSTRAINT [DF_ConfigurationELS_FeeLamination] DEFAULT (0),
  [MissingDaily] [decimal](18, 2) NULL,
  [PhotoRequired] [bit] NULL CONSTRAINT [DF_ConfigurationELS_PhotoRequired] DEFAULT (0),
  [FingerRequired] [bit] NULL CONSTRAINT [DF_ConfigurationELS_FingerRequired] DEFAULT (0),
  [ClientFingerPrintConfigurationTypeId] [int] NULL,
  [DaysTrust] [int] NULL,
  [PostdatedChecks] [int] NULL,
  [cityStickerDiscount] [decimal](18, 2) NOT NULL DEFAULT (0),
  [registrationRenewalDiscount] [decimal](18, 2) NOT NULL DEFAULT (0),
  [ExitTimeExceded] [int] NULL,
  [InsuranceRegistrationReleaseFee] [decimal](18, 2) NOT NULL DEFAULT (0),
  CONSTRAINT [PK_ELSConfiguration] PRIMARY KEY CLUSTERED ([ConfigurationELSId])
)
ON [PRIMARY]
GO