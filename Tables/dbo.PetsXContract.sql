CREATE TABLE [dbo].[PetsXContract] (
  [PetIdXContract] [int] IDENTITY,
  [Quantity] [int] NOT NULL,
  [ContractId] [int] NOT NULL,
  [PetId] [int] NOT NULL,
  CONSTRAINT [PK_PetsXContract] PRIMARY KEY CLUSTERED ([PetIdXContract])
)
ON [PRIMARY]
GO