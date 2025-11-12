CREATE TABLE [dbo].[NewsXUsers] (
  [NewsXCashierId] [int] IDENTITY,
  [NewsId] [int] NOT NULL,
  [UserId] [int] NOT NULL,
  CONSTRAINT [PK_NewsXUsers] PRIMARY KEY CLUSTERED ([NewsXCashierId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[NewsXUsers]
  ADD CONSTRAINT [FK_NewsXUsers_News] FOREIGN KEY ([NewsId]) REFERENCES [dbo].[News] ([NewsId])
GO

ALTER TABLE [dbo].[NewsXUsers]
  ADD CONSTRAINT [FK_NewsXUsers_Users] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([UserId])
GO