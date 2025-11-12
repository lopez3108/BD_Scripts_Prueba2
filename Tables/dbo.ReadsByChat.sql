CREATE TABLE [dbo].[ReadsByChat] (
  [ReadByChatId] [int] IDENTITY,
  [ChatMessageId] [int] NOT NULL,
  [ReadUserId] [int] NOT NULL,
  CONSTRAINT [PK_ReadsByChat] PRIMARY KEY CLUSTERED ([ReadByChatId])
)
ON [PRIMARY]
GO

CREATE UNIQUE INDEX [IX_ReadsByChat]
  ON [dbo].[ReadsByChat] ([ChatMessageId], [ReadUserId])
  ON [PRIMARY]
GO

CREATE INDEX [IX_ReadsByChat_ChatMessageId_ReadUserId]
  ON [dbo].[ReadsByChat] ([ChatMessageId], [ReadUserId])
  ON [PRIMARY]
GO