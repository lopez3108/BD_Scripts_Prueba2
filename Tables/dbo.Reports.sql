CREATE TABLE [dbo].[Reports] (
  [ReportId] [int] IDENTITY,
  [ReportCategoryId] [int] NOT NULL,
  [ReportName] [varchar](50) NOT NULL,
  [Code] [varchar](4) NOT NULL,
  CONSTRAINT [PK_Reports_1] PRIMARY KEY CLUSTERED ([ReportId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[Reports]
  ADD CONSTRAINT [FK_Reports_ReportCategories] FOREIGN KEY ([ReportCategoryId]) REFERENCES [dbo].[ReportCategories] ([ReportCategoryId])
GO