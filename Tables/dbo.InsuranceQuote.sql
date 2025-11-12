CREATE TABLE [dbo].[InsuranceQuote] (
  [InsuranceQuoteId] [int] IDENTITY,
  [ClientName] [varchar](70) NOT NULL,
  [ClientTelephone] [varchar](10) NOT NULL,
  [Address] [varchar](100) NOT NULL,
  [GenderId] [int] NOT NULL,
  [DriverLicenseNumber] [varchar](30) NULL,
  [DriverLicenseTypeId] [int] NULL,
  [Dob] [datetime] NOT NULL,
  [MaritalStatusId] [int] NOT NULL,
  [PolicyTypeId] [int] NOT NULL,
  [InsuranceQuoteStatusCode] [varchar](4) NOT NULL,
  [StateAbre] [varchar](4) NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedInAgencyId] [int] NOT NULL,
  [ValidatedBy] [int] NULL,
  [ValidatedOn] [datetime] NULL,
  [ValidatedInAgencyId] [int] NULL,
  [LastUpdatedOn] [datetime] NOT NULL,
  [LastUpdatedBy] [int] NOT NULL,
  [InsuranceQuoteCompleteReasonId] [int] NULL,
  CONSTRAINT [PK_InsuranceQuot_1] PRIMARY KEY CLUSTERED ([InsuranceQuoteId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[InsuranceQuote]
  ADD CONSTRAINT [FK_InsuranceQuot_Agencies] FOREIGN KEY ([CreatedInAgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[InsuranceQuote]
  ADD CONSTRAINT [FK_InsuranceQuot_Agencies1] FOREIGN KEY ([ValidatedInAgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[InsuranceQuote]
  ADD CONSTRAINT [FK_InsuranceQuot_DriverLicenseType] FOREIGN KEY ([DriverLicenseTypeId]) REFERENCES [dbo].[DriverLicenseType] ([DriverLicenseTypeId])
GO

ALTER TABLE [dbo].[InsuranceQuote]
  ADD CONSTRAINT [FK_InsuranceQuot_Gender] FOREIGN KEY ([GenderId]) REFERENCES [dbo].[Gender] ([GenderId])
GO

ALTER TABLE [dbo].[InsuranceQuote]
  ADD CONSTRAINT [FK_InsuranceQuot_MaritalStatus] FOREIGN KEY ([MaritalStatusId]) REFERENCES [dbo].[MaritalStatus] ([MaritalStatusId])
GO

ALTER TABLE [dbo].[InsuranceQuote]
  ADD CONSTRAINT [FK_InsuranceQuot_PolicyType] FOREIGN KEY ([PolicyTypeId]) REFERENCES [dbo].[PolicyType] ([PolicyTypeId])
GO

ALTER TABLE [dbo].[InsuranceQuote]
  ADD CONSTRAINT [FK_InsuranceQuot_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[InsuranceQuote]
  ADD CONSTRAINT [FK_InsuranceQuot_Users1] FOREIGN KEY ([ValidatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[InsuranceQuote]
  ADD CONSTRAINT [FK_InsuranceQuot_Users2] FOREIGN KEY ([LastUpdatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[InsuranceQuote]
  ADD CONSTRAINT [FK_InsuranceQuote_InsuranceQuoteCompleteReason] FOREIGN KEY ([InsuranceQuoteCompleteReasonId]) REFERENCES [dbo].[InsuranceQuoteCompleteReason] ([InsuranceQuoteCompleteReasonId])
GO