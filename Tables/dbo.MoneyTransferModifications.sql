CREATE TABLE [dbo].[MoneyTransferModifications] (
  [MoneyTransferModificationId] [int] IDENTITY,
  [ClientName] [varchar](50) NOT NULL,
  [Telephone] [varchar](10) NOT NULL,
  [TransactionNumber] [varchar](20) NOT NULL,
  [ProviderId] [int] NOT NULL,
  [ValidationCode] [varchar](4) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [AgencyId] [int] NOT NULL,
  CONSTRAINT [PK_MoneyTransferModifications] PRIMARY KEY CLUSTERED ([MoneyTransferModificationId])
)
ON [PRIMARY]
GO