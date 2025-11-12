CREATE TABLE [dbo].[Imei] (
  [ImeiId] [int] IDENTITY,
  [Imei] [varchar](4) NOT NULL,
  [InventoryByAgencyId] [int] NOT NULL,
  CONSTRAINT [PK_Imei] PRIMARY KEY CLUSTERED ([ImeiId]),
  CONSTRAINT [IX_Imei_InventoryId] UNIQUE ([InventoryByAgencyId], [Imei])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[Imei]
  ADD CONSTRAINT [FK_Imei_Inventory] FOREIGN KEY ([InventoryByAgencyId]) REFERENCES [dbo].[InventoryByAgency] ([InventoryByAgencyId])
GO