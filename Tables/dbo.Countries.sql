CREATE TABLE [dbo].[Countries] (
  [CountryId] [int] IDENTITY,
  [Name] [varchar](50) NOT NULL,
  [Currency] [varchar](4) NULL,
  [CountryAbre] [varchar](4) NULL,
  CONSTRAINT [PK_Countries] PRIMARY KEY CLUSTERED ([CountryId])
)
ON [PRIMARY]
GO