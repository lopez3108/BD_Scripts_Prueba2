CREATE TABLE [dbo].[ReturnsELS] (
  [ReturnsELSId] [int] IDENTITY,
  [InventoryELSId] [int] NOT NULL,
  [Number] [varchar](20) NOT NULL,
  [Reason] [varchar](100) NULL,
  [AgencyId] [int] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [CreatedOn] [datetime] NOT NULL,
  [ReturnsELSStatusId] [int] NOT NULL,
  [PackageNumber] [varchar](30) NULL,
  [LastUpdatedOn] [datetime] NOT NULL,
  [LastUpdatedBy] [int] NOT NULL,
  [ShippingDate] [datetime] NULL,
  [CashierId] [int] NULL,
  [ReturnType] [bit] NULL,
  [Fee] [decimal](18, 2) NULL,
  CONSTRAINT [PK_ReturnsELS] PRIMARY KEY CLUSTERED ([ReturnsELSId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[ReturnsELS]
  ADD CONSTRAINT [FK_ReturnsELS_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[ReturnsELS]
  ADD CONSTRAINT [FK_ReturnsELS_InventoryELS] FOREIGN KEY ([InventoryELSId]) REFERENCES [dbo].[InventoryELS] ([InventoryELSId])
GO

ALTER TABLE [dbo].[ReturnsELS]
  ADD CONSTRAINT [FK_ReturnsELS_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO