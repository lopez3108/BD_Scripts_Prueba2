CREATE TABLE [dbo].[ParkingTicketsCards] (
  [ParkingTicketCardId] [int] IDENTITY,
  [USD] [decimal](18, 2) NOT NULL,
  [Fee1] [decimal](18, 2) NOT NULL,
  [Fee2] [decimal](18, 2) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [CardPayment] [bit] NOT NULL CONSTRAINT [DF_ParkingTicketsCards_CardPayment] DEFAULT (0),
  [CardPaymentFee] [decimal](18, 2) NULL,
  [MoneyOrderNumber] [varchar](20) NULL,
  [MoneyOrderFee] [decimal](18, 2) NULL,
  [CardBankId] [int] NULL,
  [BankAccountId] [int] NULL,
  [TicketPaymentTypeId] [int] NULL,
  [FileIdName] [varchar](1000) NULL,
  [UpdatedOn] [datetime] NULL,
  [UpdatedBy] [int] NULL,
  [ExpenseId] [int] NULL,
  CONSTRAINT [PK_ParkingTicketsCards] PRIMARY KEY CLUSTERED ([ParkingTicketCardId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[ParkingTicketsCards]
  ADD FOREIGN KEY ([ExpenseId]) REFERENCES [dbo].[Expenses] ([ExpenseId])
GO

ALTER TABLE [dbo].[ParkingTicketsCards]
  ADD CONSTRAINT [FK_ParkingTicketsCards_Agency] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[ParkingTicketsCards]
  ADD CONSTRAINT [FK_ParkingTicketsCards_BankAccounts] FOREIGN KEY ([BankAccountId]) REFERENCES [dbo].[BankAccounts] ([BankAccountId])
GO

ALTER TABLE [dbo].[ParkingTicketsCards]
  ADD CONSTRAINT [FK_ParkingTicketsCards_CardBanks] FOREIGN KEY ([CardBankId]) REFERENCES [dbo].[CardBanks] ([CardBankId])
GO

ALTER TABLE [dbo].[ParkingTicketsCards]
  ADD CONSTRAINT [FK_ParkingTicketsCards_TicketPaymentTypes] FOREIGN KEY ([TicketPaymentTypeId]) REFERENCES [dbo].[TicketPaymentTypes] ([TicketPaymentTypeId])
GO

ALTER TABLE [dbo].[ParkingTicketsCards]
  ADD CONSTRAINT [FK_ParkingTicketsCards_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO