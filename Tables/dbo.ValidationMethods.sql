CREATE TABLE [dbo].[ValidationMethods] (
  [ValidationMethodId] [int] IDENTITY,
  [Name] [varchar](50) NOT NULL,
  [DescriptionTranslate] [varchar](200) NOT NULL,
  [Code] [varchar](10) NOT NULL,
  [IsDefault] [bit] NOT NULL CONSTRAINT [DF_ValidationMethods_IsDefault] DEFAULT (0),
  CONSTRAINT [PK_ValidationMethods] PRIMARY KEY CLUSTERED ([ValidationMethodId])
)
ON [PRIMARY]
GO