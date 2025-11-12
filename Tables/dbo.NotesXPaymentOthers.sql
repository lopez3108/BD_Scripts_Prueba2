CREATE TABLE [dbo].[NotesXPaymentOthers] (
  [NotesXPaymentOtherId] [int] IDENTITY,
  [CreatedBy] [int] NOT NULL,
  [Note] [varchar](2000) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [PaymentOthersId] [int] NOT NULL,
  CONSTRAINT [PK_NotesXPaymentOthers_NotesXPaymentOtherIs] PRIMARY KEY CLUSTERED ([NotesXPaymentOtherId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[NotesXPaymentOthers]
  ADD CONSTRAINT [FK_NotesXPaymentOthers_CreatedBy] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[NotesXPaymentOthers]
  ADD CONSTRAINT [FK_NotesXPaymentOthers_PaymentOthersId] FOREIGN KEY ([PaymentOthersId]) REFERENCES [dbo].[PaymentOthers] ([PaymentOthersId])
GO