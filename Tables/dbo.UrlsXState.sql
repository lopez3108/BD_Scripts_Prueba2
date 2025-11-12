CREATE TABLE [dbo].[UrlsXState] (
  [UrlXStateId] [int] IDENTITY,
  [StateAbre] [nvarchar](5) NULL,
  [State] [nvarchar](255) NOT NULL,
  [Entities] [varchar](500) NOT NULL,
  [Link] [varchar](500) NOT NULL,
  CONSTRAINT [PK_UrlsXState] PRIMARY KEY CLUSTERED ([UrlXStateId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[UrlsXState]
  ADD CONSTRAINT [FK_UrlsXState_UrlsXState] FOREIGN KEY ([UrlXStateId]) REFERENCES [dbo].[UrlsXState] ([UrlXStateId])
GO