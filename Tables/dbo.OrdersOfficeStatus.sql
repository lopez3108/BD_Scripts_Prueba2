CREATE TABLE [dbo].[OrdersOfficeStatus] (
  [OrdersOfficeStatusId] [int] IDENTITY,
  [Code] [varchar](10) NOT NULL,
  [Description] [varchar](30) NOT NULL,
  CONSTRAINT [PK_OrdersOfficeStatus] PRIMARY KEY CLUSTERED ([OrdersOfficeStatusId])
)
ON [PRIMARY]
GO