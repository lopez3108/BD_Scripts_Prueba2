CREATE TABLE [dbo].[MoneyTransferxAgencyNumbers] (
  [MoneyTransferxAgencyNumbersId] [int] IDENTITY,
  [AgencyId] [int] NOT NULL,
  [ProviderId] [int] NOT NULL,
  [Number] [varchar](40) NOT NULL,
  CONSTRAINT [PK_MoneyTransferxAgencyCodes] PRIMARY KEY CLUSTERED ([MoneyTransferxAgencyNumbersId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[MoneyTransferxAgencyNumbers]
  ADD FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO