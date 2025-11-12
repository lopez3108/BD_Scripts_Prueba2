CREATE TABLE [dbo].[ProviderStatements] (
  [ProviderStatementsId] [int] IDENTITY,
  [Year] [int] NOT NULL,
  [Month] [int] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [ProviderId] [int] NOT NULL,
  [CreationDate] [datetime] NULL,
  [UserId] [int] NULL,
  [Name] [varchar](150) NULL,
  [Extension] [varchar](25) NULL,
  [Base64] [varchar](max) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO