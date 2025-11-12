CREATE TABLE [dbo].[PhoneSales] (
  [PhoneSalesId] [int] IDENTITY,
  [PurchaseValue] [decimal](18, 2) NOT NULL,
  [SellingValue] [decimal](18, 2) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [Imei] [varchar](10) NOT NULL,
  [PhonePlanId] [int] NULL,
  [InventoryByAgencyId] [int] NOT NULL,
  [CardPayment] [bit] NOT NULL CONSTRAINT [DF_PhoneSales_CardPayment] DEFAULT (0),
  [CardPaymentFee] [decimal](18, 2) NULL,
  [OnlyPhone] [bit] NOT NULL DEFAULT (0),
  [Tax] [decimal](18, 2) NOT NULL CONSTRAINT [DF_PhoneSales_Tax] DEFAULT (0),
  [LastUpdatedOn] [datetime] NULL,
  [LastUpdatedBy] [int] NULL,
  [Cash] [decimal](18, 2) NULL,
  [ExpenseId] [int] NULL,
  [CashierCommission] [decimal](18, 2) NULL,
  CONSTRAINT [PK_dbo.PhoneSales] PRIMARY KEY CLUSTERED ([PhoneSalesId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[PhoneSales]
  ADD FOREIGN KEY ([ExpenseId]) REFERENCES [dbo].[Expenses] ([ExpenseId])
GO

ALTER TABLE [dbo].[PhoneSales]
  ADD CONSTRAINT [FK_PhoneSales_Agencies] FOREIGN KEY ([InventoryByAgencyId]) REFERENCES [dbo].[InventoryByAgency] ([InventoryByAgencyId])
GO

ALTER TABLE [dbo].[PhoneSales]
  ADD CONSTRAINT [FK_PhoneSales_PhonePlans] FOREIGN KEY ([PhonePlanId]) REFERENCES [dbo].[PhonePlans] ([PhonePlanId])
GO