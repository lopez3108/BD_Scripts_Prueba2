CREATE TABLE [dbo].[CompanyInformation] (
  [CompanyInformationId] [int] IDENTITY,
  [Name] [varchar](150) NOT NULL,
  [Telephone] [varchar](20) NOT NULL,
  [Address] [varchar](150) NOT NULL,
  [ReceiptLogo] [varchar](200) NULL,
  [ZipCode] [nvarchar](50) NULL,
  CONSTRAINT [PK_CompanyInformation] PRIMARY KEY CLUSTERED ([CompanyInformationId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[CompanyInformation]
  ADD CONSTRAINT [FK_CompanyInformation_CompanyInformation] FOREIGN KEY ([ZipCode]) REFERENCES [dbo].[ZipCodes] ([ZipCode])
GO