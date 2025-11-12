CREATE TABLE [dbo].[PaymentCashAgentToAgent] (
  [PaymentCashId] [int] IDENTITY,
  [AgencyId] [int] NOT NULL,
  [ProviderId] [int] NOT NULL,
  [USD] [decimal](18, 2) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [DeletedOn] [datetime] NULL,
  [DeletedBy] [datetime] NULL,
  [CreatedBy] [int] NOT NULL,
  [Date] [datetime] NOT NULL,
  [FromAgencyId] [int] NOT NULL,
  CONSTRAINT [PK_PaymentCashAgentToAgent] PRIMARY KEY CLUSTERED ([PaymentCashId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[PaymentCashAgentToAgent]
  ADD CONSTRAINT [FK_PaymentCashAgentToAgent_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[PaymentCashAgentToAgent]
  ADD CONSTRAINT [FK_PaymentCashAgentToAgent_FromAgencies] FOREIGN KEY ([FromAgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[PaymentCashAgentToAgent]
  ADD CONSTRAINT [FK_PaymentCashAgentToAgent_Providers] FOREIGN KEY ([ProviderId]) REFERENCES [dbo].[Providers] ([ProviderId])
GO