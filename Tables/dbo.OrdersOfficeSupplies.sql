CREATE TABLE [dbo].[OrdersOfficeSupplies] (
  [OrderOfficeSupplieId] [int] IDENTITY,
  [OrderDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [SentOn] [datetime] NULL,
  [SentBy] [int] NULL,
  [ConpletedOn] [datetime] NULL,
  [CompletedBy] [int] NULL,
  CONSTRAINT [PK_OrdersOfficeSupplies] PRIMARY KEY CLUSTERED ([OrderOfficeSupplieId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[OrdersOfficeSupplies]
  ADD CONSTRAINT [FK_OrdersOfficeSupplies_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[OrdersOfficeSupplies]
  ADD CONSTRAINT [FK_OrdersOfficeSupplies_Users2] FOREIGN KEY ([SentBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[OrdersOfficeSupplies]
  ADD CONSTRAINT [FK_OrdersOfficeSupplies_Users3] FOREIGN KEY ([CompletedBy]) REFERENCES [dbo].[Users] ([UserId])
GO