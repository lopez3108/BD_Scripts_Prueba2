CREATE TABLE [dbo].[OtherPayments] (
  [OtherPaymentId] [int] IDENTITY,
  [Description] [varchar](150) NULL,
  [Usd] [decimal](18, 2) NULL,
  [CreatedBy] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [CardPayment] [bit] NULL CONSTRAINT [DF_OtherPayments_CardPayment] DEFAULT (0),
  [CardPaymentFee] [decimal](18, 2) NULL,
  [LastUpdatedOn] [datetime] NULL,
  [LastUpdatedBy] [int] NULL,
  [Cash] [decimal](18, 2) NULL,
  [PayMissing] [bit] NULL,
  [UsdMissing] [decimal](18, 2) NULL,
  [UsdPayMissing] [decimal](18, 2) NULL,
  [DailyId] [int] NULL,
  [completed] [bit] NULL DEFAULT (0),
  [CompletedBy] [varchar](50) NULL,
  [CompletedOn] [datetime] NULL,
  CONSTRAINT [PK_OtherPayments] PRIMARY KEY CLUSTERED ([OtherPaymentId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[OtherPayments]
  ADD CONSTRAINT [FK_OtherPayments_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO