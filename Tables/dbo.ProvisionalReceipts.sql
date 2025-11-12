CREATE TABLE [dbo].[ProvisionalReceipts] (
  [ProvisionalReceiptId] [int] IDENTITY,
  [CompanyName] [varchar](30) NOT NULL,
  [Total] [decimal](18, 2) NOT NULL,
  [OtherFees] [decimal](18, 2) NULL,
  [CardPaymentFee] [decimal](18, 2) NULL,
  [CardPayment] [bit] NOT NULL CONSTRAINT [DF_ProvisionalReceipts_CardPayment] DEFAULT (0),
  [Cash] [decimal](18, 2) NOT NULL,
  [Change] [decimal](18, 2) NOT NULL,
  [Completed] [bit] NOT NULL CONSTRAINT [DF_ProvisionalReceipts_Pending] DEFAULT (0),
  [AgencyId] [int] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [Telephone] [varchar](15) NULL,
  [CompanyId] [int] NULL,
  [Account] [varchar](50) NULL,
  [CompletedBy] [int] NULL,
  [CompletedOn] [datetime] NULL,
  [TelIsCheck] [bit] NULL CONSTRAINT [DF_ProvisionalReceipts_TelIsCheckUSA] DEFAULT (0),
  [TelephoneUSA] [varchar](14) NULL,
  [AccountIsCheck] [bit] NULL CONSTRAINT [DF_ProvisionalReceipts_TelIsCheck] DEFAULT (0),
  [ClientName] [varchar](50) NULL,
  [TypeOfInternationalTopUpsId] [int] NULL,
  [CountryId] [int] NULL,
  [TransactionNumber] [varchar](50) NULL,
  CONSTRAINT [PK_ProvisionalReceipts] PRIMARY KEY CLUSTERED ([ProvisionalReceiptId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[ProvisionalReceipts]
  ADD CONSTRAINT [FK_ProvisionalReceipts_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[ProvisionalReceipts]
  ADD CONSTRAINT [FK_ProvisionalReceipts_Cashiers] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Cashiers] ([CashierId])
GO