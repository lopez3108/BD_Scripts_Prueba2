CREATE TABLE [dbo].[PaymentChecksAgentToAgent] (
  [PaymentChecksAgentToAgentId] [int] IDENTITY,
  [FromAgency] [int] NOT NULL,
  [ToAgency] [int] NOT NULL,
  [Date] [datetime] NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  [NumberChecks] [int] NOT NULL,
  [StatusId] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [DeletedOn] [datetime] NULL,
  [DeletedBy] [int] NULL,
  [FromDate] [datetime] NULL,
  [ToDate] [datetime] NULL,
  [ProviderId] [int] NOT NULL,
  [Fee] [decimal](18, 2) NOT NULL CONSTRAINT [DF__PaymentChec__Fee__3E9D2825] DEFAULT (0),
  [LotNumber] [smallint] NULL,
  [UpdatedOn] [datetime] NULL,
  [UpdatedBy] [int] NULL,
  [IsFromAdmin] [bit] NULL,
  [ProviderCheckfee] [decimal](18, 2) NULL,
  [providerBatch] [varchar](50) NULL,
  CONSTRAINT [PK_PaymentChecksAgentToAgent] PRIMARY KEY CLUSTERED ([PaymentChecksAgentToAgentId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[PaymentChecksAgentToAgent]
  ADD CONSTRAINT [FK_PaymentChecksAgentToAgent_FromAgencies] FOREIGN KEY ([FromAgency]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[PaymentChecksAgentToAgent]
  ADD CONSTRAINT [FK_PaymentChecksAgentToAgent_Providers] FOREIGN KEY ([ProviderId]) REFERENCES [dbo].[Providers] ([ProviderId])
GO

ALTER TABLE [dbo].[PaymentChecksAgentToAgent]
  ADD CONSTRAINT [FK_PaymentChecksAgentToAgent_ToAgencies] FOREIGN KEY ([ToAgency]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[PaymentChecksAgentToAgent]
  ADD CONSTRAINT [FK_PaymentChecksAgentToAgent_Users] FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

DECLARE @value SQL_VARIANT = CAST(N'' AS nvarchar(1))
EXEC sys.sp_addextendedproperty N'MS_Description', @value, 'SCHEMA', N'dbo', 'TABLE', N'PaymentChecksAgentToAgent'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Número de lote por fecha y por userId', 'SCHEMA', N'dbo', 'TABLE', N'PaymentChecksAgentToAgent', 'COLUMN', N'LotNumber'
GO