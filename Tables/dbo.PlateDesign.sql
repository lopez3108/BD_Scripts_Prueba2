CREATE TABLE [dbo].[PlateDesign] (
  [PlateDesignId] [int] IDENTITY,
  [Code] [varchar](5) NULL,
  [Description] [varchar](30) NULL,
  PRIMARY KEY CLUSTERED ([PlateDesignId])
)
ON [PRIMARY]
GO