CREATE TABLE [dbo].[PublishExchangeRatesByAgency] (
  [PublishExchangeRatesByAgencyId] [int] IDENTITY,
  [PublishExchangeRateId] [int] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [ConfirmDate] [datetime] NOT NULL,
  [ConfirmBy] [int] NOT NULL,
  CONSTRAINT [PK_PublishExchangeRatesByAgency] PRIMARY KEY CLUSTERED ([PublishExchangeRatesByAgencyId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[PublishExchangeRatesByAgency]
  ADD CONSTRAINT [FK_PublishExchangeRatesByAgency_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[PublishExchangeRatesByAgency]
  ADD CONSTRAINT [FK_PublishExchangeRatesByAgency_PublishExchangeRates] FOREIGN KEY ([PublishExchangeRateId]) REFERENCES [dbo].[PublishExchangeRates] ([PublishExchangeRateId])
GO