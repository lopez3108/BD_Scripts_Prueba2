CREATE TABLE [dbo].[InventoryELS] (
  [InventoryELSId] [int] IDENTITY,
  [Code] [varchar](10) NOT NULL,
  [Description] [varchar](50) NOT NULL,
  [AlertQuantity] [int] NOT NULL DEFAULT (10),
  [InventoryFormFileName] [varchar](100) NULL,
  [InventoryFormRequired] [bit] NOT NULL DEFAULT (0),
  [IsPersonalInventory] [bit] NOT NULL DEFAULT (0),
  [AlertActive] [bit] NOT NULL CONSTRAINT [DF_InventoryELS_AlertActive] DEFAULT (0),
  CONSTRAINT [PK_InventoryELS] PRIMARY KEY CLUSTERED ([InventoryELSId])
)
ON [PRIMARY]
GO