CREATE TABLE [dbo].[InventoryELSByAgency] (
  [InventoryELSByAgencyId] [int] IDENTITY,
  [AgencyId] [int] NOT NULL,
  [InventoryELSId] [int] NOT NULL,
  [InStock] [int] NOT NULL,
  [CashierId] [int] NULL,
  CONSTRAINT [PK_InventoryELSByAgency] PRIMARY KEY CLUSTERED ([InventoryELSByAgencyId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[InventoryELSByAgency]
  ADD CONSTRAINT [FK_InventoryELSByAgency_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[InventoryELSByAgency]
  ADD CONSTRAINT [FK_InventoryELSByAgency_InventoryELS] FOREIGN KEY ([InventoryELSId]) REFERENCES [dbo].[InventoryELS] ([InventoryELSId])
GO