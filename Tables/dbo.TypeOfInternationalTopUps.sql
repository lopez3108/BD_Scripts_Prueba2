CREATE TABLE [dbo].[TypeOfInternationalTopUps] (
  [TypeOfInternationalTopUpsId] [int] IDENTITY,
  [Name] [varchar](50) NULL,
  [Code] [varchar](3) NULL,
  CONSTRAINT [PK_TypeOfInternationalTopUps] PRIMARY KEY CLUSTERED ([TypeOfInternationalTopUpsId])
)
ON [PRIMARY]
GO