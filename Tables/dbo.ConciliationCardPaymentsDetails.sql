CREATE TABLE [dbo].[ConciliationCardPaymentsDetails] (
  [ConciliationCardPaymentsDetailsId] [int] IDENTITY,
  [ConciliationCardPaymentId] [int] NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  PRIMARY KEY CLUSTERED ([ConciliationCardPaymentsDetailsId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[ConciliationCardPaymentsDetails]
  ADD CONSTRAINT [FK_ConciliationCardPaymentsDetails_ConciliationCardPayments] FOREIGN KEY ([ConciliationCardPaymentId]) REFERENCES [dbo].[ConciliationCardPayments] ([ConciliationCardPaymentId])
GO