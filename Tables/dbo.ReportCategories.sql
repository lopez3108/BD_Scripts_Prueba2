CREATE TABLE [dbo].[ReportCategories] (
  [ReportCategoryId] [int] IDENTITY,
  [CategoryCode] [char](10) NOT NULL,
  [CategoryName] [varchar](200) NOT NULL,
  CONSTRAINT [PK_ReportCategories] PRIMARY KEY CLUSTERED ([ReportCategoryId]),
  CONSTRAINT [IX_ReportCategories] UNIQUE ([CategoryCode]),
  CONSTRAINT [IX_ReportCategories_1] UNIQUE ([CategoryName])
)
ON [PRIMARY]
GO