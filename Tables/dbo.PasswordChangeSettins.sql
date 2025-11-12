CREATE TABLE [dbo].[PasswordChangeSettins] (
  [PasswordChangeId] [int] IDENTITY,
  [Name] [varchar](50) NOT NULL,
  [Code] [varchar](10) NOT NULL,
  [IsDefault] [bit] NOT NULL
)
ON [PRIMARY]
GO