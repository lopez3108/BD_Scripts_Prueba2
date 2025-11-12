CREATE TABLE [dbo].[Daily] (
  [DailyId] [int] IDENTITY,
  [CashierId] [int] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [Total] [decimal](18, 2) NOT NULL CONSTRAINT [DF_Daily_Total] DEFAULT (0),
  [TotalFree] [decimal](18, 2) NULL CONSTRAINT [DF_Daily_TotalFree] DEFAULT (0),
  [Cash] [decimal](18, 2) NOT NULL CONSTRAINT [DF_Daily_Cash] DEFAULT (0),
  [Missing] [decimal](18, 2) NOT NULL CONSTRAINT [DF_Daily_Missing] DEFAULT (0),
  [Surplus] [decimal](18, 2) NOT NULL CONSTRAINT [DF_Daily_Surplus] DEFAULT (0),
  [Note] [varchar](300) NULL,
  [LastEditedOn] [datetime] NULL,
  [LastEditedBy] [int] NULL,
  [CashAdmin] [decimal](18, 2) NOT NULL CONSTRAINT [DF_Daily_CashAdmin] DEFAULT (0),
  [ClosedOn] [datetime] NULL,
  [ClosedBy] [int] NULL,
  [CardPayments] [decimal](18, 2) NOT NULL CONSTRAINT [DF_Daily_CardPayments] DEFAULT (0),
  [CardPaymentsAdmin] [decimal](18, 2) NOT NULL CONSTRAINT [DF_Daily_CardPayments1] DEFAULT (0),
  [ClosedOnCashAdmin] [datetime] NULL,
  [ClosedByCashAdmin] [int] NULL,
  [ClosedOnCardPaymentsAdmin] [datetime] NULL,
  [ClosedByCardPaymentsAdmin] [int] NULL,
  [ClosedTime] [time] NULL,
  CONSTRAINT [PK_Daily] PRIMARY KEY CLUSTERED ([DailyId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[Daily]
  ADD CONSTRAINT [FK_Daily_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[Daily]
  ADD CONSTRAINT [FK_Daily_Cashiers] FOREIGN KEY ([CashierId]) REFERENCES [dbo].[Cashiers] ([CashierId])
GO

ALTER TABLE [dbo].[Daily] WITH NOCHECK
  ADD CONSTRAINT [FK_Daily_Users] FOREIGN KEY ([LastEditedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[Daily] WITH NOCHECK
  ADD CONSTRAINT [FK_Daily_Users_ClosedBy] FOREIGN KEY ([ClosedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[Daily] WITH NOCHECK
  ADD CONSTRAINT [FK_Daily_Users_ClosedByCardPaymentAdmin] FOREIGN KEY ([ClosedByCardPaymentsAdmin]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[Daily] WITH NOCHECK
  ADD CONSTRAINT [FK_Daily_Users_ClosedByCashAdmin] FOREIGN KEY ([ClosedByCashAdmin]) REFERENCES [dbo].[Users] ([UserId])
GO