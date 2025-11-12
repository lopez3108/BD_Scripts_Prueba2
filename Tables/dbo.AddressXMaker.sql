CREATE TABLE [dbo].[AddressXMaker] (
  [AddressXMakerId] [int] IDENTITY,
  [MakerId] [int] NOT NULL,
  [Address] [varchar](70) NULL,
  [ZipCode] [varchar](6) NULL,
  [State] [varchar](20) NULL,
  [City] [varchar](20) NULL,
  [County] [varchar](20) NULL,
  CONSTRAINT [PK_AddressXMaker] PRIMARY KEY CLUSTERED ([AddressXMakerId])
)
ON [PRIMARY]
GO