CREATE TABLE [dbo].[ComissionHeadphonesAndChargersSettings] (
  [ComisionHeadphonesAndChargersSettingId] [int] IDENTITY,
  [Headphones] [decimal](18, 2) NOT NULL,
  [Chargers] [decimal](18, 2) NOT NULL,
  CONSTRAINT [PK_ComissionHeadphonesAndChargersSettings] PRIMARY KEY CLUSTERED ([ComisionHeadphonesAndChargersSettingId])
)
ON [PRIMARY]
GO