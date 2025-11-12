CREATE TABLE [dbo].[Inventory] (
  [InventoryId] [int] IDENTITY,
  [Model] [varchar](30) NOT NULL,
  [PurchaseValue] [decimal](18, 2) NOT NULL,
  [SellingValue] [decimal](18, 2) NOT NULL,
  CONSTRAINT [PK_Inventory] PRIMARY KEY CLUSTERED ([InventoryId])
)
ON [PRIMARY]
GO