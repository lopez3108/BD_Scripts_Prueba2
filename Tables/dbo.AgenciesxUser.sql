CREATE TABLE [dbo].[AgenciesxUser] (
  [AgenciesxUserId] [int] IDENTITY,
  [UserId] [int] NOT NULL,
  [AgencyId] [nchar](10) NOT NULL,
  CONSTRAINT [PK_AgenciesxUser] PRIMARY KEY CLUSTERED ([AgenciesxUserId])
)
ON [PRIMARY]
GO