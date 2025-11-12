CREATE TABLE [dbo].[InsuranceCompanies] (
  [InsuranceCompaniesId] [int] IDENTITY,
  [Name] [varchar](200) NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [LastUpdatedBy] [int] NOT NULL,
  [LastUpdatedOn] [datetime] NOT NULL,
  [URL] [varchar](400) NULL,
  CONSTRAINT [PK__Insuranc__F33916EAE76B035F] PRIMARY KEY CLUSTERED ([InsuranceCompaniesId])
)
ON [PRIMARY]
GO