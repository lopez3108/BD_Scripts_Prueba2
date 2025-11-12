CREATE TABLE [dbo].[PlateStickers] (
  [PlateStickerId] [int] IDENTITY,
  [USD] [decimal](18, 2) NOT NULL,
  [Fee1] [decimal](18, 2) NOT NULL,
  [Cash] [decimal](18, 2) NULL,
  [CreationDate] [datetime] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [CardPayment] [bit] NOT NULL CONSTRAINT [DF_PlateStickers_CardPayment] DEFAULT (0),
  [CardPaymentFee] [decimal](18, 2) NULL,
  [FeeEls] [decimal](18, 2) NOT NULL CONSTRAINT [DF_PlateStickers_FeeEls] DEFAULT (0),
  [UpdatedOn] [datetime] NULL,
  [UpdatedBy] [int] NULL,
  [ExpenseId] [int] NULL,
  [CashierCommission] [decimal](18, 2) NULL,
  CONSTRAINT [PK_PlateStickers] PRIMARY KEY CLUSTERED ([PlateStickerId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[PlateStickers]
  ADD FOREIGN KEY ([ExpenseId]) REFERENCES [dbo].[Expenses] ([ExpenseId])
GO

ALTER TABLE [dbo].[PlateStickers]
  ADD CONSTRAINT [FK_PlateStickers_Agency] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[PlateStickers]
  ADD CONSTRAINT [FK_PlateStickers_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO