CREATE TABLE [dbo].[InventoryELSAlerts] (
  [InventoryELSAlertId] [int] IDENTITY,
  [InventoryELSId] [int] NOT NULL,
  [QuantityOrdered] [int] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [ClosedDate] [datetime] NULL,
  [ClosedBy] [int] NULL
)
ON [PRIMARY]
GO