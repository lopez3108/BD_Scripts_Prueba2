CREATE TABLE [dbo].[ReviewXUsers] (
  [ReviewXUserId] [int] IDENTITY,
  [ReviewId] [int] NOT NULL,
  [UserId] [int] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [SIgnName] [varchar](500) NOT NULL,
  [LastCompleteOn] [datetime] NOT NULL,
  [ReviewerId] [int] NOT NULL,
  [ComplianceOfficerId] [int] NOT NULL,
  CONSTRAINT [PK_ReviewXUsers] PRIMARY KEY CLUSTERED ([ReviewXUserId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[ReviewXUsers]
  ADD CONSTRAINT [FK_ReviewXUsers_AgencyId] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[ReviewXUsers]
  ADD CONSTRAINT [FK_ReviewXUsers_Reviews] FOREIGN KEY ([ReviewId]) REFERENCES [dbo].[Reviews] ([ReviewId])
GO

ALTER TABLE [dbo].[ReviewXUsers]
  ADD CONSTRAINT [FK_ReviewXUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[ReviewXUsers]
  ADD CONSTRAINT [FK_ReviewXUsers_Users] FOREIGN KEY ([ReviewerId]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[ReviewXUsers]
  ADD CONSTRAINT [FK_ReviewXUsers_Users1] FOREIGN KEY ([ComplianceOfficerId]) REFERENCES [dbo].[Users] ([UserId])
GO