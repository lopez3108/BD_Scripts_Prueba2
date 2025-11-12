CREATE TABLE [dbo].[Expenses] (
  [ExpenseId] [int] IDENTITY,
  [ExpenseTypeId] [int] NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  [BillTypeId] [int] NULL,
  [MonthsId] [int] NULL,
  [Year] [int] NULL,
  [ReceiptNumber] [varchar](50) NULL,
  [ProviderName] [varchar](50) NULL,
  [ProviderId] [int] NULL,
  [Company] [varchar](50) NULL,
  [TransactionNumber] [varchar](15) NULL,
  [Sender] [varchar](50) NULL,
  [Recipient] [varchar](50) NULL,
  [Quantity] [int] NULL,
  [MoneyOrderNumber] [varchar](20) NULL,
  [Description] [varchar](200) NULL,
  [AgencyId] [int] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [CreatedOn] [datetime] NOT NULL,
  [ValidatedBy] [int] NULL,
  [Validated] [bit] NULL CONSTRAINT [DF_Expenses_Validated] DEFAULT (0),
  [RefundCashierId] [int] NULL,
  [RefundSurplusDate] [datetime] NULL,
  [CashierId] [int] NULL,
  [CitySticker] [decimal](18, 2) NULL,
  [CityStickerCommission] [decimal](18, 2) NULL,
  [PlateSticker] [decimal](18, 2) NULL,
  [PlateStickerCommission] [decimal](18, 2) NULL,
  [ParkingTicket] [decimal](18, 2) NULL,
  [ParkingTicketCommission] [decimal](18, 2) NULL,
  [ParkingTicketCard] [decimal](18, 2) NULL,
  [ParkingTicketCardCommission] [decimal](18, 2) NULL,
  [TitlesAndPlates] [decimal](18, 2) NULL,
  [TitlesAndPlatesCommission] [decimal](18, 2) NULL,
  [TitlesAndPlatesManual] [decimal](18, 2) NULL,
  [TitlesAndPlatesManualCommission] [decimal](18, 2) NULL,
  [Trp730] [decimal](18, 2) NULL,
  [Trp730Commissions] [decimal](18, 2) NULL,
  [Financing] [decimal](18, 2) NULL,
  [FinancingCommission] [decimal](18, 2) NULL,
  [Telephones] [decimal](18, 2) NULL,
  [TelephonesCommission] [decimal](18, 2) NULL,
  [Notary] [decimal](18, 2) NULL,
  [NotaryCommission] [decimal](18, 2) NULL,
  [Lendify] [decimal](18, 2) NULL,
  [LendifyCommission] [decimal](18, 2) NULL,
  [LendifyCompany] [decimal](18, 2) NULL,
  [LendifyCompanyCommission] [decimal](18, 2) NULL,
  [Tickets] [decimal](18, 2) NULL,
  [TicketsCommission] [decimal] NULL,
  [UpdatedBy] [int] NULL,
  [UpdatedOn] [datetime] NULL,
  [FileIdNameExpenses] [varchar](500) NULL,
  [ValidatedOn] [datetime] NULL,
  [FromDate] [datetime] NULL,
  [ToDate] [datetime] NULL,
  CONSTRAINT [PK_Expenses] PRIMARY KEY CLUSTERED ([ExpenseId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[Expenses]
  ADD CONSTRAINT [FK_Expenses_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[Expenses]
  ADD CONSTRAINT [FK_Expenses_BillTypes] FOREIGN KEY ([BillTypeId]) REFERENCES [dbo].[BillTypes] ([BillTypeId])
GO

ALTER TABLE [dbo].[Expenses]
  ADD CONSTRAINT [FK_Expenses_ExpensesType] FOREIGN KEY ([ExpenseTypeId]) REFERENCES [dbo].[ExpensesType] ([ExpensesTypeId])
GO

ALTER TABLE [dbo].[Expenses]
  ADD CONSTRAINT [FK_Expenses_Months] FOREIGN KEY ([MonthsId]) REFERENCES [dbo].[Months] ([MonthId])
GO

ALTER TABLE [dbo].[Expenses]
  ADD CONSTRAINT [FK_ExpensesCreatedBy_User] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[Expenses] WITH NOCHECK
  ADD CONSTRAINT [FK_ExpensesUpdatedBy_Users] FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[Expenses]
  NOCHECK CONSTRAINT [FK_ExpensesUpdatedBy_Users]
GO

ALTER TABLE [dbo].[Expenses] WITH NOCHECK
  ADD CONSTRAINT [FK_ExpensesValidated_Users] FOREIGN KEY ([ValidatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[Expenses]
  NOCHECK CONSTRAINT [FK_ExpensesValidated_Users]
GO