CREATE TABLE [dbo].[PlateTypesPersonalized] (
  [PlateTypePersonalizedId] [int] IDENTITY,
  [Description] [varchar](55) NOT NULL,
  CONSTRAINT [PK_PlateTypesPersonalized] PRIMARY KEY CLUSTERED ([PlateTypePersonalizedId])
)
ON [PRIMARY]
GO