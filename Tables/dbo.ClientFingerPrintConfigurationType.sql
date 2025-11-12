CREATE TABLE [dbo].[ClientFingerPrintConfigurationType] (
  [ClientFingerPrintConfigurationTypeId] [int] IDENTITY,
  [Code] [varchar](4) NOT NULL,
  [Description] [varchar](20) NOT NULL,
  PRIMARY KEY CLUSTERED ([ClientFingerPrintConfigurationTypeId])
)
ON [PRIMARY]
GO