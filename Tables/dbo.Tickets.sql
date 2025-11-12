CREATE TABLE [dbo].[Tickets] (
  [TicketId] [int] IDENTITY,
  [TicketNumber] [varchar](30) NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  [TicketStatusId] [int] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CompletedBy] [int] NULL,
  [CompletedDate] [datetime] NULL,
  [AgencyId] [int] NOT NULL,
  [ClientName] [varchar](70) NOT NULL,
  [ClientTelephone] [varchar](12) NOT NULL,
  [Fee1] [decimal](18, 2) NOT NULL,
  [Fee2] [decimal](18, 2) NOT NULL,
  [UpdateToPendingDate] [datetime] NULL,
  [UpdateToPendingBy] [int] NULL,
  [MoneyOrderNumber] [varchar](20) NULL,
  [MoneyOrderFee] [decimal](18, 2) NULL,
  [CardBankId] [int] NULL,
  [BankAccountId] [int] NULL,
  [CityCompletedDate] [date] NULL,
  [FileImageName] [varchar](max) NULL,
  [ChangedToPendingByAgency] [int] NULL,
  [MoFileImageName] [varchar](max) NULL,
  [TicketPaymentTypeId] [int] NULL,
  [CardPayment] [bit] NOT NULL CONSTRAINT [DF_Tickets_CardPayment] DEFAULT (0),
  [CardPaymentFee] [decimal](18, 2) NULL,
  [TelIsCheck] [bit] NULL,
  [LastUpdatedBy] [int] NULL,
  [LastUpdatedOn] [datetime] NULL,
  [Cash] [decimal](18, 2) NULL,
  [UpdateToPendingShippingDate] [datetime] NULL,
  [UpdateToPendingShippingBy] [int] NULL,
  [Tollway] [bit] NOT NULL CONSTRAINT [DF_Tickets_Tollway] DEFAULT (0),
  [Others] [bit] NOT NULL CONSTRAINT [DF_Tickets_Others] DEFAULT (0),
  [PlateNumber] [varchar](10) NULL,
  [StateAbre] [nvarchar](255) NULL,
  [FileNameOthers] [varchar](max) NULL,
  [ExpenseId] [int] NULL,
  [CashierCommission] [decimal](18, 2) NULL,
  [TransactionId] [varchar](36) NULL,
  [AchUsd] [decimal](18, 2) NULL,
  [UpdatedToPendingByAdmin] [bit] NOT NULL DEFAULT (0),
  [TransactionFee] [decimal](18, 2) NULL,
  [TransactionGuid ] [uniqueidentifier] NULL,
  [ClientLanguage] [bit] NOT NULL DEFAULT (0),
  [Fee2DefaultUsd] [decimal](18, 2) NULL,
  [UsdGreaterValue] [decimal](18, 2) NULL,
  [UsdLessEqualValue] [decimal](18, 2) NULL,
  [PaidComisionMoneyOrderFee] [bit] NULL,
  [ProviderCommissionPaymentId] [int] NULL,
  CONSTRAINT [PK_Tickets] PRIMARY KEY CLUSTERED ([TicketId]),
  CONSTRAINT [IX_Tickets_Number_Agency] UNIQUE ([TicketNumber])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE UNIQUE INDEX [TransactionId_Index]
  ON [dbo].[Tickets] ([TransactionId])
  WHERE ([TransactionId] IS NOT NULL)
  ON [PRIMARY]
GO

ALTER TABLE [dbo].[Tickets]
  ADD FOREIGN KEY ([ExpenseId]) REFERENCES [dbo].[Expenses] ([ExpenseId])
GO

ALTER TABLE [dbo].[Tickets]
  ADD CONSTRAINT [FK_Tickets_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[Tickets]
  ADD CONSTRAINT [FK_Tickets_BankAccountId] FOREIGN KEY ([BankAccountId]) REFERENCES [dbo].[BankAccounts] ([BankAccountId])
GO

ALTER TABLE [dbo].[Tickets]
  ADD CONSTRAINT [FK_Tickets_CardBanks] FOREIGN KEY ([CardBankId]) REFERENCES [dbo].[CardBanks] ([CardBankId])
GO

ALTER TABLE [dbo].[Tickets]
  ADD CONSTRAINT [FK_Tickets_TicketStatus] FOREIGN KEY ([TicketStatusId]) REFERENCES [dbo].[TicketStatus] ([TicketStatusId])
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Language prefeence of client 1= english 0 = spanish', 'SCHEMA', N'dbo', 'TABLE', N'Tickets'
GO