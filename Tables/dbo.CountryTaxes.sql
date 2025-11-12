CREATE TABLE [dbo].[CountryTaxes] (
  [CountryTaxId] [int] IDENTITY,
  [USD] [decimal](18, 2) NOT NULL,
  [Fee1] [decimal](18, 2) NOT NULL,
  [Cash] [decimal](18, 2) NULL,
  [CreationDate] [datetime] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [CardPayment] [bit] NOT NULL CONSTRAINT [DF_CountryTaxes_CardPayment] DEFAULT (0),
  [CardPaymentFee] [decimal](18, 2) NULL,
  [FeeEls] [decimal](18, 2) NOT NULL CONSTRAINT [DF_CountryTaxes_FeeEls] DEFAULT (0),
  [UpdatedBy] [int] NULL,
  [UpdatedOn] [datetime] NULL,
  CONSTRAINT [PK_CountryTax] PRIMARY KEY CLUSTERED ([CountryTaxId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[CountryTaxes]
  ADD CONSTRAINT [FK_CountryTaxes_Agency] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[CountryTaxes]
  ADD CONSTRAINT [FK_CountryTaxes_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO