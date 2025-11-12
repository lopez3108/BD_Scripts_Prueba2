CREATE TABLE [dbo].[ComisionReturnedChecksSettings] (
  [ComisionReturnedCheckSettingId] [int] IDENTITY,
  [Fee] [decimal](18, 2) NOT NULL,
  CONSTRAINT [PK_ComisionReturnedChecksSettings] PRIMARY KEY CLUSTERED ([ComisionReturnedCheckSettingId])
)
ON [PRIMARY]
GO