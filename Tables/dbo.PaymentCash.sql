CREATE TABLE [dbo].[PaymentCash] (
  [PaymentCashId] [int] IDENTITY,
  [AgencyId] [int] NOT NULL,
  [ProviderId] [int] NOT NULL,
  [USD] [decimal](18, 2) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [DeletedOn] [datetime] NULL,
  [DeletedBy] [datetime] NULL,
  [CreatedBy] [int] NOT NULL,
  [Date] [datetime] NULL,
  [FileImageName] [varchar](1000) NULL,
  [Status] [int] NULL,
  CONSTRAINT [PK_PaymentCash] PRIMARY KEY CLUSTERED ([PaymentCashId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[PaymentCash]
  ADD CONSTRAINT [FK_PaymentCash_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[PaymentCash]
  ADD CONSTRAINT [FK_PaymentCash_Provider] FOREIGN KEY ([ProviderId]) REFERENCES [dbo].[Providers] ([ProviderId])
GO