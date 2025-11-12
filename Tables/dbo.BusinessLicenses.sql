CREATE TABLE [dbo].[BusinessLicenses] (
  [BusinessLicenseId] [int] IDENTITY,
  [AgencyId] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [UserId] [int] NOT NULL,
  [Name] [varchar](150) NULL,
  [Extension] [varchar](25) NOT NULL,
  [Base64] [varchar](max) NULL,
  [ExpirationDate] [datetime] NOT NULL,
  PRIMARY KEY CLUSTERED ([BusinessLicenseId])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[BusinessLicenses]
  ADD FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[BusinessLicenses]
  ADD CONSTRAINT [FK__BusinessLicense__UserI] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([UserId])
GO