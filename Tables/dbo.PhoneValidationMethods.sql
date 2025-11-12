CREATE TABLE [dbo].[PhoneValidationMethods] (
  [PhoneValidationMethodId] [int] IDENTITY,
  [Name] [varchar](50) NOT NULL,
  [DescriptionTranslate] [varchar](200) NOT NULL,
  [Code] [varchar](10) NOT NULL,
  [IsDefault] [bit] NOT NULL CONSTRAINT [DF_PhoneValidationMethods_IsDefault] DEFAULT (0),
  CONSTRAINT [PK_PhoneValidationMethods] PRIMARY KEY CLUSTERED ([PhoneValidationMethodId])
)
ON [PRIMARY]
GO