CREATE TABLE [dbo].[ClientCompany] (
  [ClientCompanyId] [int] IDENTITY,
  [CompanyName] [varchar](100) NOT NULL,
  [CompanyTelephone] [varchar](10) NOT NULL,
  [CompanyEmail] [varchar](150) NOT NULL,
  [CompanyAddress] [varchar](150) NOT NULL,
  [CompanyZipCode] [varchar](5) NOT NULL,
  [CompanyWebsite] [varchar](200) NULL,
  [CompanyFax] [varchar](10) NULL,
  [CompanyLogo] [varchar](200) NULL,
  [ContactName] [varchar](100) NULL,
  [RegistrationDate] [datetime] NOT NULL,
  [RegistrationMethod] [int] NULL,
  PRIMARY KEY CLUSTERED ([ClientCompanyId])
)
ON [PRIMARY]
GO