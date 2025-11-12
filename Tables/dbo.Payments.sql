CREATE TABLE [dbo].[Payments] (
  [PaymentId] [int] IDENTITY,
  [FinancingId] [int] NOT NULL,
  [USD] [decimal](18, 2) NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [CreatedOn] [datetime] NOT NULL,
  [CardPayment] [bit] NOT NULL CONSTRAINT [DF_Payments_CardPayment] DEFAULT (0),
  [CardPaymentFee] [decimal](18, 2) NULL,
  CONSTRAINT [PK_Payments] PRIMARY KEY CLUSTERED ([PaymentId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[Payments]
  ADD CONSTRAINT [FK_Payments_Financing] FOREIGN KEY ([FinancingId]) REFERENCES [dbo].[Financing] ([FinancingId])
GO