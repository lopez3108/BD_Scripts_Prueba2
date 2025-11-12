CREATE TABLE [dbo].[InventoryByAgency] (
  [InventoryByAgencyId] [int] IDENTITY,
  [AgencyId] [int] NOT NULL,
  [InventoryId] [int] NOT NULL,
  [InStock] [int] NOT NULL,
  CONSTRAINT [PK_InventoryByAgency] PRIMARY KEY CLUSTERED ([InventoryByAgencyId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[InventoryByAgency]
  ADD CONSTRAINT [FK_InventoryByAgency_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[InventoryByAgency]
  ADD CONSTRAINT [FK_InventoryByAgency_Inventory] FOREIGN KEY ([InventoryId]) REFERENCES [dbo].[Inventory] ([InventoryId])
GO