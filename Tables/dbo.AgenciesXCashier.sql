CREATE TABLE [dbo].[AgenciesXCashier] (
  [AgenciesxCashierId] [int] IDENTITY,
  [AgencyId] [int] NOT NULL,
  [CashierId] [int] NOT NULL,
  CONSTRAINT [PK_AgenciesXCashier] PRIMARY KEY CLUSTERED ([AgenciesxCashierId])
)
ON [PRIMARY]
GO