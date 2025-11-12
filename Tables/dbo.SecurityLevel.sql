CREATE TABLE [dbo].[SecurityLevel] (
  [SecurityLevelId] [int] IDENTITY,
  [Name] [varchar](50) NOT NULL,
  [DescriptionTranslate] [varchar](200) NOT NULL,
  [Code] [varchar](10) NOT NULL,
  [IsDefault] [bit] NOT NULL CONSTRAINT [DF_SecurityLevel_IsDefault] DEFAULT (0),
  CONSTRAINT [PK_SecurityLevel] PRIMARY KEY CLUSTERED ([SecurityLevelId])
)
ON [PRIMARY]
GO