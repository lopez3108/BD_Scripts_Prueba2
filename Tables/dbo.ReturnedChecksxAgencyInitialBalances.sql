CREATE TABLE [dbo].[ReturnedChecksxAgencyInitialBalances] (
  [ReturnedChecksxAgencyInitialBalanceId] [int] IDENTITY,
  [AgencyId] [int] NOT NULL,
  [InitialBalance] [decimal](18, 2) NOT NULL,
  PRIMARY KEY CLUSTERED ([ReturnedChecksxAgencyInitialBalanceId])
)
ON [PRIMARY]
GO