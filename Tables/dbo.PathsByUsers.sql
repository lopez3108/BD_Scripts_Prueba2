CREATE TABLE [dbo].[PathsByUsers] (
  [PahtByUserId] [int] IDENTITY,
  [PathResource] [varchar](500) NULL,
  [CreatedBy] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [ParentId] [int] NULL,
  [RolesAllowed] [varchar](100) NULL,
  [UpdatedBy] [int] NULL,
  [UpdatedOn] [datetime] NULL,
  CONSTRAINT [PK_PathByUsers] PRIMARY KEY CLUSTERED ([PahtByUserId])
)
ON [PRIMARY]
GO

CREATE UNIQUE INDEX [IX_PathsByUsers_UniquePathResource]
  ON [dbo].[PathsByUsers] ([PathResource])
  ON [PRIMARY]
GO

ALTER TABLE [dbo].[PathsByUsers]
  ADD CONSTRAINT [FK_PathByUsers_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[PathsByUsers] WITH NOCHECK
  ADD CONSTRAINT [FK_PathsByUsersUpdated_Users] FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[PathsByUsers]
  NOCHECK CONSTRAINT [FK_PathsByUsersUpdated_Users]
GO