CREATE TABLE [dbo].[AddressXClient] (
  [AddressXClientId] [int] IDENTITY,
  [ClientId] [int] NOT NULL,
  [Address] [varchar](70) NULL,
  [ZipCode] [varchar](6) NULL,
  [State] [varchar](20) NULL,
  [City] [varchar](20) NULL,
  [County] [varchar](20) NULL,
  CONSTRAINT [PK_AddressXClient] PRIMARY KEY CLUSTERED ([AddressXClientId])
)
ON [PRIMARY]
GO