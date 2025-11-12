CREATE TABLE [dbo].[SmartSafeDeposit] (
  [SmartSafeDepositId] [int] IDENTITY,
  [ProviderId] [int] NOT NULL,
  [TransactionId] [varchar](15) NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  [Voucher] [varchar](50) NULL,
  [UserId] [int] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [LastUpdatedOn] [datetime] NULL,
  [LastUpdatedBy] [int] NULL,
  CONSTRAINT [PK_SmartSafeDeposit] PRIMARY KEY CLUSTERED ([SmartSafeDepositId]),
  CONSTRAINT [IX_Smart_Safe_TransactionId] UNIQUE ([TransactionId], [AgencyId], [ProviderId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[SmartSafeDeposit]
  ADD CONSTRAINT [FK_SmartSafeDeposit_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[SmartSafeDeposit]
  ADD CONSTRAINT [FK_SmartSafeDeposit_Providers] FOREIGN KEY ([ProviderId]) REFERENCES [dbo].[Providers] ([ProviderId])
GO

ALTER TABLE [dbo].[SmartSafeDeposit]
  ADD CONSTRAINT [FK_SmartSafeDeposit_UserId] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([UserId])
GO