CREATE TABLE [dbo].[ComisionCardFeeDebitSetting] (
  [ComisionCardFeeDebitSettingId] [int] IDENTITY,
  [From] [decimal](18, 2) NOT NULL,
  [To] [decimal](18, 2) NOT NULL,
  [Fee] [decimal](18, 2) NOT NULL,
  [IsDefault] [bit] NOT NULL,
  [IsPercent] [bit] NOT NULL,
  [Usd] [decimal](18, 2) NULL,
  CONSTRAINT [PK_ComisionCardFeeDebitSetting] PRIMARY KEY CLUSTERED ([ComisionCardFeeDebitSettingId])
)
ON [PRIMARY]
GO