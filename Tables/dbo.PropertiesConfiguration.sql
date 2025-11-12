CREATE TABLE [dbo].[PropertiesConfiguration] (
  [PropertiesConfigurationId] [int] IDENTITY,
  [FeeDue] [decimal](18, 2) NULL,
  [Dayslate] [int] NULL,
  [MonthlyPaymentDate] [int] NULL,
  [DaysMaxiAband] [int] NULL,
  [FeeNfs] [decimal](18, 2) NULL,
  [FeeDueLateLegend] [varchar](3500) NULL,
  [DepositLegend] [varchar](3500) NULL,
  [MoveInFeeLegend] [varchar](3500) NULL,
  [SendTextConsentLegend] [varchar](3500) NULL,
  [DepositRefundFee] [decimal](18, 2) NOT NULL DEFAULT (0),
  PRIMARY KEY CLUSTERED ([PropertiesConfigurationId])
)
ON [PRIMARY]
GO