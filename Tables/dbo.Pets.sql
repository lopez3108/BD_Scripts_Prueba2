CREATE TABLE [dbo].[Pets] (
  [PetId] [int] IDENTITY,
  [Code] [varchar](3) NOT NULL,
  [Name] [varchar](15) NOT NULL,
  CONSTRAINT [PK_Pets] PRIMARY KEY CLUSTERED ([PetId])
)
ON [PRIMARY]
GO