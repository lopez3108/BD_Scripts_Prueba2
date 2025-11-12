CREATE TABLE [dbo].[OrderOfficeSuppliesDetails] (
  [OrderOfficeSuppliesDetailsId] [int] IDENTITY,
  [OrderOfficeSupplieId] [int] NOT NULL,
  [OfficeSupplieId] [int] NOT NULL,
  [Quantity] [int] NOT NULL,
  [Status] [int] NULL,
  [AgencyId] [int] NULL,
  [SentOn] [datetime] NULL,
  [SentBy] [int] NULL,
  [CompletedOn] [datetime] NULL,
  [CompletedBy] [int] NULL,
  [RefundDate] [datetime] NULL,
  [CompletedRefundBy] [int] NULL,
  CONSTRAINT [PK_OrderOfficeSuppliesDetails] PRIMARY KEY CLUSTERED ([OrderOfficeSuppliesDetailsId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[OrderOfficeSuppliesDetails]
  ADD CONSTRAINT [FK_OrderOfficeSuppliesDetails_OfficeSupplies] FOREIGN KEY ([OfficeSupplieId]) REFERENCES [dbo].[OfficeSupplies] ([OfficeSupplieId])
GO

ALTER TABLE [dbo].[OrderOfficeSuppliesDetails]
  ADD CONSTRAINT [FK_OrderOfficeSuppliesDetails_OrdersOfficeSupplies] FOREIGN KEY ([OrderOfficeSupplieId]) REFERENCES [dbo].[OrdersOfficeSupplies] ([OrderOfficeSupplieId])
GO