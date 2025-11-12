CREATE TABLE [dbo].[Access] (
  [AccessId] [int] IDENTITY,
  [UserId] [int] NOT NULL,
  [Token] [varchar](300) NULL,
  [ExpirationDate] [datetime] NOT NULL,
  CONSTRAINT [PK__Access__4130D05FBB3A49D9] PRIMARY KEY CLUSTERED ([AccessId])
)
ON [PRIMARY]
GO