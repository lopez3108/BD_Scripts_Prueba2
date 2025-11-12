CREATE TABLE [dbo].[SellerStatus] (
  [SellerId] [int] IDENTITY,
  [Code] [varchar](3) NOT NULL,
  [Description] [varchar](20) NOT NULL
)
ON [PRIMARY]
GO