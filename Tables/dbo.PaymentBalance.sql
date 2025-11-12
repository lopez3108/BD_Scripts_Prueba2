CREATE TABLE [dbo].[PaymentBalance] (
  [PaymentBalanceId] [int] IDENTITY,
  [AgencyId] [int] NOT NULL,
  [ProviderId] [int] NOT NULL,
  [USD] [decimal](18, 2) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [DeletedOn] [datetime] NULL,
  [DeletedBy] [datetime] NULL,
  [Date] [datetime] NOT NULL,
  [FileBalance] [varchar](max) NULL,
  [Cost] [decimal](18, 2) NOT NULL,
  [Commission] [decimal](18, 2) NOT NULL,
  [Year] [smallint] NOT NULL,
  [Month] [smallint] NOT NULL,
  CONSTRAINT [PK_PaymentBalance] PRIMARY KEY CLUSTERED ([PaymentBalanceId])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[PaymentBalance]
  ADD CONSTRAINT [FK_PaymentBalance_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[PaymentBalance]
  ADD CONSTRAINT [FK_PaymentBalance_Providers] FOREIGN KEY ([ProviderId]) REFERENCES [dbo].[Providers] ([ProviderId])
GO