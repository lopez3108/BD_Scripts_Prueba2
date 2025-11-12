CREATE TABLE [dbo].[CommisionVentraSetting] (
  [ComisionVentraSettingId] [int] IDENTITY,
  [Reload] [decimal](18, 2) NOT NULL,
  CONSTRAINT [PK_CommisionVentraSetting] PRIMARY KEY CLUSTERED ([ComisionVentraSettingId])
)
ON [PRIMARY]
GO