CREATE TABLE [dbo].[ElsxAgencyInitialBalances] (
  [ElsxAgencyInitialBalanceId] [int] IDENTITY,
  [AgencyId] [int] NOT NULL,
  [ProviderId] [int] NOT NULL,
  [InitialBalance] [decimal](18, 2) NOT NULL,
  [LastUpdatedOn] [datetime] NULL,
  [CreatedBy] [int] NULL,
  [ConfigurationSavedDate] [datetime] NULL,
  CONSTRAINT [PK_ElsxAgencyInitialBalances] PRIMARY KEY CLUSTERED ([ElsxAgencyInitialBalanceId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[ElsxAgencyInitialBalances]
  ADD FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[ElsxAgencyInitialBalances]
  ADD CONSTRAINT [FK_ElsxAgencyInitialBalances_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[ElsxAgencyInitialBalances]
  ADD CONSTRAINT [FK_ElsxAgencyInitialBalances_Providers] FOREIGN KEY ([ProviderId]) REFERENCES [dbo].[Providers] ([ProviderId])
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Configuracion de valores iniciales para provider (vehicle services)', 'SCHEMA', N'dbo', 'TABLE', N'ElsxAgencyInitialBalances'
GO