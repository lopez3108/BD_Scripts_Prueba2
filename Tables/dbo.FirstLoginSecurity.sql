CREATE TABLE [dbo].[FirstLoginSecurity] (
  [RolId] [int] IDENTITY,
  [ApplyToAdmin] [bit] NOT NULL DEFAULT (0),
  [ApplyToCashier] [bit] NOT NULL DEFAULT (0),
  [ApplyToManager] [bit] NOT NULL DEFAULT (0),
  CONSTRAINT [PK_FirtLoginSecurity_RolId] PRIMARY KEY CLUSTERED ([RolId])
)
ON [PRIMARY]
GO