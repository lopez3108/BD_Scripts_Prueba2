CREATE TABLE [dbo].[ExchangeRates] (
  [ExchangeRateId] [int] IDENTITY,
  [CountryId] [int] NOT NULL,
  [ProviderId] [int] NOT NULL,
  [Payer] [varchar](70) NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  [LastUpdatedBy] [int] NOT NULL,
  [LastUpdatedOn] [datetime] NOT NULL,
  CONSTRAINT [PK_ExchangeRates] PRIMARY KEY CLUSTERED ([ExchangeRateId]),
  CONSTRAINT [IX_ExchangeRates] UNIQUE ([CountryId], [ProviderId], [Payer])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[ExchangeRates]
  ADD CONSTRAINT [FK_ExchangeRates_Countries] FOREIGN KEY ([CountryId]) REFERENCES [dbo].[Countries] ([CountryId])
GO

ALTER TABLE [dbo].[ExchangeRates]
  ADD CONSTRAINT [FK_ExchangeRates_Providers] FOREIGN KEY ([ProviderId]) REFERENCES [dbo].[Providers] ([ProviderId])
GO

ALTER TABLE [dbo].[ExchangeRates]
  ADD CONSTRAINT [FK_ExchangeRates_Users] FOREIGN KEY ([LastUpdatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO