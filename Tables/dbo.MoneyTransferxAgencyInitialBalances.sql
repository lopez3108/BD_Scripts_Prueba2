CREATE TABLE [dbo].[MoneyTransferxAgencyInitialBalances] (
  [MoneyTransferxAgencyInitialBalanceId] [int] IDENTITY,
  [AgencyId] [int] NOT NULL,
  [ProviderId] [int] NOT NULL,
  [InitialBalance] [decimal](18, 2) NOT NULL,
  [ConfigurationSavedDate] [datetime] NULL,
  [LastUpdatedOn] [datetime] NULL,
  [CreatedBy] [int] NULL,
  PRIMARY KEY CLUSTERED ([MoneyTransferxAgencyInitialBalanceId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[MoneyTransferxAgencyInitialBalances]
  ADD FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[MoneyTransferxAgencyInitialBalances]
  ADD FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO