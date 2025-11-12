CREATE TABLE [dbo].[UsersConnectedChat] (
  [ConnectionId] [varchar](50) NOT NULL,
  [IsOnline] [bit] NOT NULL CONSTRAINT [DF_UsersConnectedChat_IsOnline] DEFAULT (0),
  [AgencyConnectedId] [int] NULL,
  [UserId] [int] NOT NULL,
  [Rol] [varchar](15) NOT NULL,
  CONSTRAINT [PK_UsersConnectedChat] PRIMARY KEY CLUSTERED ([ConnectionId])
)
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Connection id generated from signlr ', 'SCHEMA', N'dbo', 'TABLE', N'UsersConnectedChat', 'COLUMN', N'ConnectionId'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Status for chat [Online -Offline]', 'SCHEMA', N'dbo', 'TABLE', N'UsersConnectedChat', 'COLUMN', N'IsOnline'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Agency in that user is connected or logged', 'SCHEMA', N'dbo', 'TABLE', N'UsersConnectedChat', 'COLUMN', N'AgencyConnectedId'
GO