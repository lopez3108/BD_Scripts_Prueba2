CREATE TABLE [dbo].[UsersXGroup] (
  [UserXGroupId] [int] IDENTITY,
  [GroupId] [int] NOT NULL,
  [UserId] [int] NOT NULL,
  [CreationDate] [datetime] NULL,
  [CreatedBy] [int] NULL,
  CONSTRAINT [PK_GruposXUsers] PRIMARY KEY CLUSTERED ([UserXGroupId])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_UsersXGroup_GroupId_UserId_CreationDate]
  ON [dbo].[UsersXGroup] ([GroupId], [UserId], [CreationDate])
  ON [PRIMARY]
GO