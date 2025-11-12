CREATE TABLE [dbo].[AddressXRouting] (
  [AddressXRoutingId] [int] IDENTITY,
  [RoutingId] [int] NOT NULL,
  [Address] [varchar](70) NOT NULL,
  [ZipCode] [varchar](6) NOT NULL,
  [State] [varchar](20) NOT NULL,
  [City] [varchar](20) NOT NULL,
  [County] [varchar](20) NULL,
  PRIMARY KEY CLUSTERED ([AddressXRoutingId])
)
ON [PRIMARY]
GO