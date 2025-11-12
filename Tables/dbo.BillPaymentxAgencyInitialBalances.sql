CREATE TABLE [dbo].[BillPaymentxAgencyInitialBalances] (
  [BillPaymentxAgencyInitialBalanceId] [int] IDENTITY,
  [AgencyId] [int] NOT NULL,
  [ProviderId] [int] NOT NULL,
  [InitialBalance] [decimal](18, 2) NOT NULL,
  [LastUpdatedOn] [datetime] NULL,
  [CreatedBy] [int] NULL,
  [ConfigurationSavedDate] [datetime] NULL,
  PRIMARY KEY CLUSTERED ([BillPaymentxAgencyInitialBalanceId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[BillPaymentxAgencyInitialBalances]
  ADD FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[BillPaymentxAgencyInitialBalances]
  ADD FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Configuracion de valores iniciales para provider (bill payment)', 'SCHEMA', N'dbo', 'TABLE', N'BillPaymentxAgencyInitialBalances'
GO