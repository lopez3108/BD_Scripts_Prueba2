CREATE TABLE [dbo].[CompanyType] (
  [CompanyType] [int] NOT NULL,
  [Code] [varchar](3) NULL,
  [CompanyTypeName] [varchar](50) NULL,
  CONSTRAINT [PK__CompanyT__87E16DD2A647CEF2] PRIMARY KEY CLUSTERED ([CompanyType])
)
ON [PRIMARY]
GO