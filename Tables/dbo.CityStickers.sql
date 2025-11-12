CREATE TABLE [dbo].[CityStickers] (
  [CityStickerId] [int] IDENTITY,
  [USD] [decimal](18, 2) NOT NULL,
  [Cash] [decimal](18, 2) NULL,
  [Fee1] [decimal](18, 2) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [CardPayment] [bit] NOT NULL CONSTRAINT [DF_CityStickers_CardPayment] DEFAULT (0),
  [CardPaymentFee] [decimal](18, 2) NULL,
  [FeeEls] [decimal](18, 2) NOT NULL CONSTRAINT [DF_CityStickers_FeeEls] DEFAULT (0),
  [UpdatedBy] [int] NULL,
  [UpdatedOn] [datetime] NULL,
  [CashierCommission] [decimal](18, 2) NULL,
  [ExpenseId] [int] NULL,
  [TitleParentId] [int] NULL,
  CONSTRAINT [PK_CityStickers] PRIMARY KEY CLUSTERED ([CityStickerId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[CityStickers]
  ADD FOREIGN KEY ([ExpenseId]) REFERENCES [dbo].[Expenses] ([ExpenseId])
GO

ALTER TABLE [dbo].[CityStickers]
  ADD CONSTRAINT [FK_CityStickers_Agency] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[CityStickers]
  ADD CONSTRAINT [FK_CityStickers_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO