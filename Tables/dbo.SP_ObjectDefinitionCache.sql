CREATE TABLE [dbo].[SP_ObjectDefinitionCache] (
  [ObjectName] [nvarchar](255) NOT NULL,
  [Definition] [nvarchar](max) NULL,
  [CapturedAt] [datetime] NULL DEFAULT (getdate()),
  PRIMARY KEY CLUSTERED ([ObjectName])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO