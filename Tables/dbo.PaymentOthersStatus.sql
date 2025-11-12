CREATE TABLE [dbo].[PaymentOthersStatus] (
  [PaymentOtherStatusId] [int] IDENTITY,
  [Name] [varchar](20) NOT NULL,
  [Code] [varchar](3) NOT NULL,
  CONSTRAINT [PK_PaymentOthersStatus_StatusPaymentOtherId] PRIMARY KEY CLUSTERED ([PaymentOtherStatusId])
)
ON [PRIMARY]
GO