CREATE TABLE [dbo].[TypeOfSearch] (
  [TypeOfSearchId] [int] IDENTITY,
  [Code] [varchar](3) NULL,
  [Description] [varchar](15) NULL,
  CONSTRAINT [PK_TypeOfSearch] PRIMARY KEY CLUSTERED ([TypeOfSearchId])
)
ON [PRIMARY]
GO