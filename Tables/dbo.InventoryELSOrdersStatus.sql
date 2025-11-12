CREATE TABLE [dbo].[InventoryELSOrdersStatus] (
  [InventoryELSOrdersStatusId] [int] IDENTITY,
  [Code] [varchar](3) NOT NULL,
  [Description] [varchar](30) NOT NULL,
  PRIMARY KEY CLUSTERED ([InventoryELSOrdersStatusId])
)
ON [PRIMARY]
GO