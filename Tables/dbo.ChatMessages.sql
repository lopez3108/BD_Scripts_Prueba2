CREATE TABLE [dbo].[ChatMessages] (
  [ChatMessageId] [int] IDENTITY,
  [MessageGuid] [varchar](300) NOT NULL,
  [ToGroupId] [int] NULL,
  [ToUserId] [int] NULL,
  [FromUserId] [int] NULL,
  [Time] [datetime] NOT NULL,
  [Message] [varchar](2000) NULL,
  [ChatStatusId] [int] NOT NULL CONSTRAINT [DF_Table_1_Read] DEFAULT (0),
  [IsFile] [bit] NULL CONSTRAINT [DF_ChatMessages_IsFile] DEFAULT (0),
  [Extension] [varchar](10) NULL,
  [ChatColor] [varchar](30) NULL,
  [ParentId] [int] NULL,
  [FromSystem] [bit] NULL,
  [Edited] [bit] NULL,
  [EditedOn] [datetime] NULL,
  [Deleted] [bit] NULL,
  [DeletedOn] [datetime] NULL,
  [Forwarded] [bit] NULL,
  CONSTRAINT [PK_ChatMessages] PRIMARY KEY CLUSTERED ([ChatMessageId])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_ChatMessages_ToGroupId_Time_FromUserId_ToUserId]
  ON [dbo].[ChatMessages] ([ToGroupId], [Time], [FromUserId], [ToUserId])
  ON [PRIMARY]
GO

ALTER TABLE [dbo].[ChatMessages]
  ADD CONSTRAINT [FK_ChatMessages_ChatStatus] FOREIGN KEY ([ChatStatusId]) REFERENCES [dbo].[ChatStatus] ([ChatStatusId])
GO