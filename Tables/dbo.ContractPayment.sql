CREATE TABLE [dbo].[ContractPayment] (
  [ContractPaymentId] [int] IDENTITY,
  [ContractId] [int] NOT NULL,
  [Date] [datetime] NOT NULL,
  [USD] [decimal](18, 2) NOT NULL
)
ON [PRIMARY]
GO