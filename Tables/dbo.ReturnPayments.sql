CREATE TABLE [dbo].[ReturnPayments] (
  [ReturnPaymentsId] [int] IDENTITY,
  [ReturnedCheckId] [int] NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [ReturnPaymentModeId] [int] NOT NULL,
  [AgencyId] [int] NULL,
  [CheckNumber] [varchar](15) NULL,
  [ValidatedOn] [datetime] NULL,
  [ValidatedBy] [int] NULL,
  [CardPayment] [bit] NOT NULL CONSTRAINT [DF_ReturnPayments_CardPayment] DEFAULT (0),
  [CardPaymentFee] [decimal](18, 2) NULL,
  [FeeDue] [decimal](18, 2) NULL,
  [LotNumber] [smallint] NULL,
  [PaymentChecksAgentToAgentId] [int] NULL,
  [Cash] [decimal](18, 2) NULL,
  [ProccesCheckReturned] [bit] NULL,
  [CheckDate] [datetime] NULL,
  [ValidatedPostdatedChecksBy] [int] NULL,
  [BankAccountId] [int] NULL,
  [AchDate] [datetime] NULL,
  CONSTRAINT [PK_ReturnPayments] PRIMARY KEY CLUSTERED ([ReturnPaymentsId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[ReturnPayments] WITH NOCHECK
  ADD CONSTRAINT [FK_ReturnPayments_PaymentChecksAgentToAgent] FOREIGN KEY ([PaymentChecksAgentToAgentId]) REFERENCES [dbo].[PaymentChecksAgentToAgent] ([PaymentChecksAgentToAgentId]) NOT FOR REPLICATION
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Número de lote por fecha y por userId', 'SCHEMA', N'dbo', 'TABLE', N'ReturnPayments', 'COLUMN', N'LotNumber'
GO