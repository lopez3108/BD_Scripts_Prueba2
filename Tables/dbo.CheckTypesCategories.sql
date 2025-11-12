CREATE TABLE [dbo].[CheckTypesCategories] (
  [CategoryCheckTypeId] [int] IDENTITY,
  [Code] [varchar](3) NOT NULL,
  [Description] [varchar](20) NOT NULL,
  CONSTRAINT [PK_CheckTypesCaregories_CategoryCheckTypeId] PRIMARY KEY CLUSTERED ([CategoryCheckTypeId])
)
ON [PRIMARY]
GO

CREATE UNIQUE INDEX [IX_DataNonRepeatCode]
  ON [dbo].[CheckTypesCategories] ([Code])
  ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Cateregorias de tipos de check type', 'SCHEMA', N'dbo', 'TABLE', N'CheckTypesCategories'
GO