CREATE TABLE [dbo].[Financing] (
  [FinancingId] [int] IDENTITY,
  [FinancingStatusId] [int] NOT NULL,
  [Trp] [varchar](10) NOT NULL,
  [Name] [varchar](50) NOT NULL,
  [Telephone] [varchar](10) NOT NULL,
  [USD] [decimal](18, 2) NOT NULL,
  [Note] [varchar](200) NULL,
  [AgencyId] [int] NOT NULL,
  [CreatedBy] [int] NULL,
  [CreatedOn] [datetime] NULL,
  [CompletedBy] [int] NULL,
  [CompletedOn] [datetime] NULL,
  [CanceledBy] [int] NULL,
  [CanceledOn] [datetime] NULL,
  [Dealer] [bit] NOT NULL CONSTRAINT [DF_Financing_Dealer] DEFAULT (0),
  [DealerName] [varchar](50) NULL,
  [ExpirationDate] [datetime] NOT NULL,
  [CancellarionFee] [decimal](18, 2) NULL,
  [CancellationUsd] [decimal](18, 2) NULL,
  [CardPayment] [bit] NOT NULL CONSTRAINT [DF_Financing_CardPayment] DEFAULT (0),
  [CardPaymentFee] [decimal](18, 2) NULL,
  [DealerNumber] [varchar](10) NULL,
  [DealerAddress] [varchar](40) NULL,
  [ExpenseId] [int] NULL,
  CONSTRAINT [PK_Financing] PRIMARY KEY CLUSTERED ([FinancingId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[Financing]
  ADD FOREIGN KEY ([ExpenseId]) REFERENCES [dbo].[Expenses] ([ExpenseId])
GO

ALTER TABLE [dbo].[Financing]
  ADD CONSTRAINT [FK_Financing_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[Financing]
  ADD CONSTRAINT [FK_Financing_FinancingStatus] FOREIGN KEY ([FinancingStatusId]) REFERENCES [dbo].[FinancingStatus] ([FinancingStatusId])
GO