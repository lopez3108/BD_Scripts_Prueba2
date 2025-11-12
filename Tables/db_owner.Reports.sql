CREATE TABLE [db_owner].[Reports] (
  [ReportId] [int] IDENTITY,
  [ReportCategoryId] [int] NOT NULL,
  [ReportName] [varchar](30) NOT NULL,
  CONSTRAINT [PK_Reports] PRIMARY KEY CLUSTERED ([ReportId])
)
ON [PRIMARY]
GO

ALTER TABLE [db_owner].[Reports]
  ADD CONSTRAINT [FK_Reports_ReportCategories] FOREIGN KEY ([ReportCategoryId]) REFERENCES [dbo].[ReportCategories] ([ReportCategoryId])
GO