CREATE TABLE [dbo].[Properties] (
  [PropertiesId] [int] IDENTITY,
  [Name] [varchar](40) NOT NULL,
  [Address] [varchar](50) NOT NULL,
  [Zipcode] [varchar](6) NOT NULL,
  [City] [varchar](20) NOT NULL,
  [State] [varchar](20) NOT NULL,
  [Telephone] [varchar](50) NULL,
  [County] [varchar](30) NULL,
  [PersonInCharge] [varchar](40) NULL,
  [PersonInChargeTelephone] [varchar](10) NULL,
  [InsuranceId] [int] NULL,
  [PolicyNumber] [varchar](20) NULL,
  [PolicyStartDate] [datetime] NULL,
  [PolicyEndDate] [datetime] NULL,
  [BillNumber] [varchar](20) NULL,
  [PropertyValue] [decimal](18, 2) NOT NULL,
  [PurchaseDate] [datetime] NOT NULL,
  [PIN] [varchar](20) NOT NULL,
  [InsuranceContactName] [varchar](50) NULL,
  [InsuranceContactTelephone] [varchar](10) NULL,
  [CreationDate] [datetime] NULL,
  [CreatedBy] [int] NULL,
  [AddressCorporation] [varchar](50) NULL,
  [EmailCorporation] [varchar](50) NULL,
  [TrustNumber] [varchar](16) NULL,
  [Zelle] [varchar](10) NULL,
  [BankAccountId] [int] NULL,
  [ZelleEmail] [varchar](100) NULL,
  [TrustCompany] [varchar](16) NULL,
  CONSTRAINT [PK_Properties] PRIMARY KEY CLUSTERED ([PropertiesId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[Properties]
  ADD CONSTRAINT [FK_Properties_BankAccounts] FOREIGN KEY ([BankAccountId]) REFERENCES [dbo].[BankAccounts] ([BankAccountId])
GO

ALTER TABLE [dbo].[Properties]
  ADD CONSTRAINT [FKInsurance_Properties] FOREIGN KEY ([InsuranceId]) REFERENCES [dbo].[Insurance] ([InsuranceId])
GO