CREATE TABLE [dbo].[InventoryOrders] (
  [InventoryOrderId] [int] IDENTITY,
  [OrderDate] [datetime] NOT NULL,
  [InventoryByAgencyId] [int] NOT NULL,
  [Units] [int] NOT NULL,
  [PurchaseValue] [decimal](18, 2) NOT NULL,
  [SellingValue] [decimal](18, 2) NOT NULL,
  [OrderedBy] [int] NOT NULL,
  CONSTRAINT [PK_InventoryOrders] PRIMARY KEY CLUSTERED ([InventoryOrderId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[InventoryOrders]
  ADD CONSTRAINT [FK_InventoryOrders_Inventory] FOREIGN KEY ([InventoryByAgencyId]) REFERENCES [dbo].[InventoryByAgency] ([InventoryByAgencyId])
GO

ALTER TABLE [dbo].[InventoryOrders]
  ADD CONSTRAINT [FK_InventoryOrders_Users] FOREIGN KEY ([OrderedBy]) REFERENCES [dbo].[Users] ([UserId])
GO