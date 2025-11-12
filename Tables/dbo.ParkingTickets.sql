CREATE TABLE [dbo].[ParkingTickets] (
  [ParkingTicketId] [int] IDENTITY,
  [USD] [decimal](18, 2) NOT NULL,
  [Fee1] [decimal](18, 2) NOT NULL,
  [Fee2] [decimal](18, 2) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [CardPayment] [bit] NOT NULL CONSTRAINT [DF_ParkingTickets_CardPayment] DEFAULT (0),
  [CardPaymentFee] [decimal](18, 2) NULL,
  [FeeEls] [decimal](18, 2) NOT NULL CONSTRAINT [DF_ParkingTickets_FeeEls] DEFAULT (0),
  [UpdatedBy] [int] NULL,
  [UpdatedOn] [datetime] NULL,
  [ExpenseId] [int] NULL,
  CONSTRAINT [PK_ParkingTickets] PRIMARY KEY CLUSTERED ([ParkingTicketId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[ParkingTickets]
  ADD FOREIGN KEY ([ExpenseId]) REFERENCES [dbo].[Expenses] ([ExpenseId])
GO

ALTER TABLE [dbo].[ParkingTickets]
  ADD CONSTRAINT [FK_ParkingTickets_Agency] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[ParkingTickets]
  ADD CONSTRAINT [FK_ParkingTickets_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO