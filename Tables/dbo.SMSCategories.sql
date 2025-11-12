CREATE TABLE [dbo].[SMSCategories] (
  [SMSCategoryId] [int] IDENTITY,
  [Code] [varchar](10) NOT NULL,
  [Description] [varchar](60) NOT NULL,
  CONSTRAINT [PK_SMSCategories] PRIMARY KEY CLUSTERED ([SMSCategoryId])
)
ON [PRIMARY]
GO

CREATE UNIQUE INDEX [IX_SMSCategories]
  ON [dbo].[SMSCategories] ([Code])
  ON [PRIMARY]
GO