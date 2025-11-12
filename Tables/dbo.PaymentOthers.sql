CREATE TABLE [dbo].[PaymentOthers] (
  [PaymentOthersId] [int] IDENTITY,
  [AgencyId] [int] NOT NULL,
  [ProviderId] [int] NULL,
  [USD] [decimal](18, 2) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [DeletedOn] [datetime] NULL,
  [DeletedBy] [int] NULL,
  [IsDebit] [bit] NOT NULL CONSTRAINT [DF__PaymentOt__IsDeb__0DEF03D2] DEFAULT (0),
  [Date] [datetime] NOT NULL,
  [PaymentOtherStatusId] [int] NOT NULL,
  [LastUpdatedOn] [datetime] NULL,
  [LastUpdatedBy] [int] NULL,
  [CompletedOn] [datetime] NULL,
  [CompletedBy] [int] NULL,
  [IsCardPayment] [bit] NULL,
  CONSTRAINT [PK__PaymentO__5E63D73A9D46A863] PRIMARY KEY CLUSTERED ([PaymentOthersId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[PaymentOthers]
  ADD CONSTRAINT [FK_PaymentOthers_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[PaymentOthers]
  ADD CONSTRAINT [FK_PaymentOthers_PaymentOtherStatusId] FOREIGN KEY ([PaymentOtherStatusId]) REFERENCES [dbo].[PaymentOthersStatus] ([PaymentOtherStatusId])
GO

ALTER TABLE [dbo].[PaymentOthers]
  ADD CONSTRAINT [FK_PaymentOthers_Providers] FOREIGN KEY ([ProviderId]) REFERENCES [dbo].[Providers] ([ProviderId])
GO