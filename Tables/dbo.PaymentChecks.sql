CREATE TABLE [dbo].[PaymentChecks] (
  [PaymentCheckId] [int] IDENTITY,
  [AgencyId] [int] NOT NULL,
  [Date] [datetime] NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  [NumberChecks] [int] NOT NULL,
  [StatusId] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [DeletedOn] [datetime] NULL,
  [DeletedBy] [int] NULL,
  [FromDate] [datetime] NOT NULL,
  [ToDate] [datetime] NOT NULL,
  [ProviderId] [int] NOT NULL,
  [Fee] [decimal](18, 2) NOT NULL,
  [LotNumber] [smallint] NULL,
  [UpdatedOn] [datetime] NULL,
  [UpdatedBy] [int] NULL,
  CONSTRAINT [PK_PaymentChecks] PRIMARY KEY CLUSTERED ([PaymentCheckId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[PaymentChecks]
  ADD CONSTRAINT [FK_PaymentChecks_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[PaymentChecks]
  ADD CONSTRAINT [FK_PaymentChecks_Providers] FOREIGN KEY ([ProviderId]) REFERENCES [dbo].[Providers] ([ProviderId])
GO

ALTER TABLE [dbo].[PaymentChecks]
  ADD CONSTRAINT [FK_PaymentChecks_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[PaymentChecks]
  ADD CONSTRAINT [FK_PaymentChecks_Users1] FOREIGN KEY ([DeletedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[PaymentChecks]
  ADD CONSTRAINT [FK_PaymentChecks_Users2] FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Número de lote por fecha y por userId', 'SCHEMA', N'dbo', 'TABLE', N'PaymentChecks', 'COLUMN', N'LotNumber'
GO