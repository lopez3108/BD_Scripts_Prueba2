CREATE TABLE [dbo].[InsuranceQuoteDriver] (
  [InsuranceQuoteDriverId] [int] IDENTITY,
  [InsuranceQuoteId] [int] NOT NULL,
  [Name] [varchar](70) NOT NULL,
  [GenderId] [int] NOT NULL,
  [DriverLicenseNumber] [varchar](30) NULL,
  [DriverLicenseTypeId] [int] NULL,
  [Dob] [datetime] NOT NULL,
  [MaritalStatusId] [int] NOT NULL,
  CONSTRAINT [PK_InsuranceQuotDriver] PRIMARY KEY CLUSTERED ([InsuranceQuoteDriverId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[InsuranceQuoteDriver]
  ADD CONSTRAINT [FK_InsuranceQuotDriver_DriverLicenseType] FOREIGN KEY ([DriverLicenseTypeId]) REFERENCES [dbo].[DriverLicenseType] ([DriverLicenseTypeId])
GO

ALTER TABLE [dbo].[InsuranceQuoteDriver]
  ADD CONSTRAINT [FK_InsuranceQuotDriver_Gender] FOREIGN KEY ([GenderId]) REFERENCES [dbo].[Gender] ([GenderId])
GO

ALTER TABLE [dbo].[InsuranceQuoteDriver]
  ADD CONSTRAINT [FK_InsuranceQuotDriver_InsuranceQuot] FOREIGN KEY ([InsuranceQuoteId]) REFERENCES [dbo].[InsuranceQuote] ([InsuranceQuoteId])
GO

ALTER TABLE [dbo].[InsuranceQuoteDriver]
  ADD CONSTRAINT [FK_InsuranceQuotDriver_InsuranceQuotDriver] FOREIGN KEY ([InsuranceQuoteDriverId]) REFERENCES [dbo].[InsuranceQuoteDriver] ([InsuranceQuoteDriverId])
GO

ALTER TABLE [dbo].[InsuranceQuoteDriver]
  ADD CONSTRAINT [FK_InsuranceQuotDriver_MaritalStatus] FOREIGN KEY ([MaritalStatusId]) REFERENCES [dbo].[MaritalStatus] ([MaritalStatusId])
GO