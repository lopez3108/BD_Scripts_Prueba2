CREATE TABLE [dbo].[Cancellations] (
  [CancellationId] [int] IDENTITY,
  [CancellationDate] [datetime] NOT NULL CONSTRAINT [DF_Cancellations_CancellationDate] DEFAULT (getdate()),
  [ClientName] [varchar](200) NOT NULL,
  [ProviderCancelledId] [int] NOT NULL,
  [ReceiptCancelledNumber] [varchar](25) NULL,
  [InitialStatusId] [int] NOT NULL,
  [ProviderNewId] [int] NULL,
  [ReceiptNewNumber] [varchar](25) NULL,
  [FinalStatusId] [int] NULL,
  [RefundDate] [datetime] NULL,
  [RefundAmount] [decimal](18, 2) NULL,
  [NewTransactionDate] [datetime] NULL,
  [TotalTransaction] [decimal](18, 2) NOT NULL,
  [Fee] [decimal](18, 2) NOT NULL,
  [CreatedBy] [int] NULL,
  [ChangedBy] [int] NULL,
  [NoteXCancellationId] [int] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [Telephone] [varchar](10) NOT NULL,
  [Email] [varchar](50) NULL,
  [RefundFee] [bit] NULL,
  [CancellationTypeId] [int] NULL,
  [TelIsCheck] [bit] NULL CONSTRAINT [DF_Cancellations_TelIsCheck] DEFAULT (0),
  [LastUpdatedBy] [int] NULL,
  [LastUpdatedOn] [datetime] NULL,
  [ValidatedBy] [int] NULL,
  [ValidatedOn] [datetime] NULL,
  [ChooseMsg] [bit] NULL,
  [ValidatedRefundManagerBy] [int] NULL,
  [ValidatedRefundManagerOn] [datetime] NULL,
  [ValidatedRefundByTelClient] [bit] NULL,
  CONSTRAINT [PK_Cancellations] PRIMARY KEY CLUSTERED ([CancellationId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[Cancellations] WITH NOCHECK
  ADD CONSTRAINT [FK_Cancellations_CancellationStatus] FOREIGN KEY ([InitialStatusId]) REFERENCES [dbo].[CancellationStatus] ([CancellationStatusId])
GO

ALTER TABLE [dbo].[Cancellations] WITH NOCHECK
  ADD CONSTRAINT [FK_Cancellations_CancellationStatus1] FOREIGN KEY ([FinalStatusId]) REFERENCES [dbo].[CancellationStatus] ([CancellationStatusId])
GO

ALTER TABLE [dbo].[Cancellations]
  ADD CONSTRAINT [FK_Cancellations_CancellationTypes] FOREIGN KEY ([CancellationTypeId]) REFERENCES [dbo].[CancellationTypes] ([CancellationTypeId])
GO

ALTER TABLE [dbo].[Cancellations] WITH NOCHECK
  ADD CONSTRAINT [FK_Cancellations_NotesxCancellations] FOREIGN KEY ([NoteXCancellationId]) REFERENCES [dbo].[NotesxCancellations] ([NoteXCancellationId])
GO

ALTER TABLE [dbo].[Cancellations] WITH NOCHECK
  ADD CONSTRAINT [FK_Cancellations_Providers] FOREIGN KEY ([ProviderCancelledId]) REFERENCES [dbo].[Providers] ([ProviderId])
GO

ALTER TABLE [dbo].[Cancellations] WITH NOCHECK
  ADD CONSTRAINT [FK_Cancellations_Providers1] FOREIGN KEY ([ProviderNewId]) REFERENCES [dbo].[Providers] ([ProviderId])
GO

ALTER TABLE [dbo].[Cancellations] WITH NOCHECK
  ADD CONSTRAINT [FK_Cancellations_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[Cancellations] WITH NOCHECK
  ADD CONSTRAINT [FK_Cancellations_Users1] FOREIGN KEY ([ChangedBy]) REFERENCES [dbo].[Users] ([UserId])
GO