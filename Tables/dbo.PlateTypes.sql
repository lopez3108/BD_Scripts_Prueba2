CREATE TABLE [dbo].[PlateTypes] (
  [PlateTypeId] [int] IDENTITY,
  [Code] [varchar](10) NOT NULL,
  [Description] [varchar](30) NOT NULL,
  [ProcessAuto] [bit] NOT NULL CONSTRAINT [DF_PlateTypes_ProcessAuto] DEFAULT (0),
  [Order] [int] NULL,
  CONSTRAINT [PK_PlateTypes] PRIMARY KEY CLUSTERED ([PlateTypeId])
)
ON [PRIMARY]
GO