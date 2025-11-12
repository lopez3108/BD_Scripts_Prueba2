CREATE TABLE [dbo].[DriverLicenseType] (
  [DriverLicenseTypeId] [int] IDENTITY,
  [Description] [varchar](30) NOT NULL,
  [Order] [int] NOT NULL CONSTRAINT [DF_DriverLicenseType_Order] DEFAULT (1),
  [Code] [varchar](3) NULL,
  CONSTRAINT [PK_DriverLicenseType] PRIMARY KEY CLUSTERED ([DriverLicenseTypeId])
)
ON [PRIMARY]
GO