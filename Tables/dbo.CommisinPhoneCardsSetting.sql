CREATE TABLE [dbo].[CommisinPhoneCardsSetting] (
  [ComisionPhoneCardsSettingId] [int] IDENTITY,
  [Percentage] [decimal](18, 2) NOT NULL,
  CONSTRAINT [PK_CommisinVentraSetting] PRIMARY KEY CLUSTERED ([ComisionPhoneCardsSettingId])
)
ON [PRIMARY]
GO