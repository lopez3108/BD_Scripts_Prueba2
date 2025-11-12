CREATE TABLE [dbo].[InstructionPaymentStatus] (
  [InstructionPaymentId] [int] IDENTITY,
  [Code] [varchar](3) NOT NULL,
  [Description] [varchar](20) NOT NULL,
  CONSTRAINT [PK_InstructionPayment] PRIMARY KEY CLUSTERED ([InstructionPaymentId])
)
ON [PRIMARY]
GO