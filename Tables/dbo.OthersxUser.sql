CREATE TABLE [dbo].[OthersxUser] (
  [OthersxUserId] [int] IDENTITY,
  [OtherId] [int] NOT NULL,
  [UserId] [int] NOT NULL,
  CONSTRAINT [PK_OthersxUser] PRIMARY KEY CLUSTERED ([OthersxUserId])
)
ON [PRIMARY]
GO