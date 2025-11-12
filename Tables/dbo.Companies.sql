CREATE TABLE [dbo].[Companies] (
  [CompanyId] [int] IDENTITY,
  [CompanyName] [varchar](40) NULL,
  [CompanyType] [int] NULL,
  CONSTRAINT [PK__Companie__2D971CACD6D1A610] PRIMARY KEY CLUSTERED ([CompanyId])
)
ON [PRIMARY]
GO

CREATE UNIQUE INDEX [IX_Company_Type_Company_Name]
  ON [dbo].[Companies] ([CompanyName], [CompanyType])
  ON [PRIMARY]
GO