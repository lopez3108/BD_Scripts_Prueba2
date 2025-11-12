CREATE TABLE [dbo].[AddressXBank] (
  [AddressXBankId] [int] IDENTITY,
  [BankId] [int] NOT NULL,
  [Address] [varchar](70) NOT NULL,
  [ZipCode] [varchar](6) NOT NULL,
  [State] [varchar](20) NOT NULL,
  [City] [varchar](20) NOT NULL,
  [County] [varchar](20) NULL,
  CONSTRAINT [PK_AddressXBank] PRIMARY KEY CLUSTERED ([AddressXBankId])
)
ON [PRIMARY]
GO