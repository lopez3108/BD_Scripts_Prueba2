CREATE TABLE [dbo].[InventoryELSOrders] (
  [InventoryELSOrderId] [int] IDENTITY,
  [OrderDate] [datetime] NOT NULL,
  [InventoryELSByAgencyId] [int] NOT NULL,
  [Units] [int] NOT NULL,
  [OrderedBy] [int] NOT NULL,
  [InventoryELSOrdersStatusId] [int] NOT NULL,
  [SentBy] [int] NULL,
  [SentDate] [datetime] NULL,
  [ClosedBy] [int] NULL,
  [ClosedDate] [datetime] NULL,
  [ClosedUnits] [int] NULL,
  [InventoryFormFileName] [varchar](100) NULL,
  CONSTRAINT [PK_InventoryELSOrders] PRIMARY KEY CLUSTERED ([InventoryELSOrderId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[InventoryELSOrders]
  ADD CONSTRAINT [FK_InventoryELSOrders_InventoryELSOrders] FOREIGN KEY ([InventoryELSByAgencyId]) REFERENCES [dbo].[InventoryELSByAgency] ([InventoryELSByAgencyId])
GO

ALTER TABLE [dbo].[InventoryELSOrders]
  ADD CONSTRAINT [FK_InventoryELSOrders_Users] FOREIGN KEY ([OrderedBy]) REFERENCES [dbo].[Users] ([UserId])
GO