CREATE TABLE [dbo].[FilesxProvider] (
  [FilesxProviderId] [int] IDENTITY,
  [ProviderId] [int] NOT NULL,
  [CreationDate] [datetime] NULL,
  [UserId] [int] NULL,
  [Name] [varchar](150) NULL,
  [Extension] [varchar](25) NULL,
  [Base64] [varchar](max) NULL,
  PRIMARY KEY CLUSTERED ([FilesxProviderId])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[FilesxProvider]
  ADD CONSTRAINT [FK__FilesxPro__Provi__6F0B5556] FOREIGN KEY ([ProviderId]) REFERENCES [dbo].[Providers] ([ProviderId])
GO

ALTER TABLE [dbo].[FilesxProvider]
  ADD CONSTRAINT [FK__FilesxPro__UserI__2D7D891B] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([UserId])
GO