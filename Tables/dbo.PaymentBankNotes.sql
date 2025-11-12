CREATE TABLE [dbo].[PaymentBankNotes] (
  [NoteXPaymentBankId] [int] IDENTITY,
  [PaymentBankId] [int] NOT NULL,
  [Note] [varchar](2000) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  CONSTRAINT [PK_PaymentBankNotes] PRIMARY KEY CLUSTERED ([NoteXPaymentBankId])
)
ON [PRIMARY]
GO