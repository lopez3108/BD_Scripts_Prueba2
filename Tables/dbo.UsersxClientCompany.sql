CREATE TABLE [dbo].[UsersxClientCompany] (
  [UsersxClientCompanyId] [int] IDENTITY,
  [UserId] [int] NOT NULL,
  [ClientCompanyId] [int] NOT NULL,
  PRIMARY KEY CLUSTERED ([UsersxClientCompanyId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[UsersxClientCompany]
  ADD CONSTRAINT [FK_UsersxClientCompany_ClientCompanyId] FOREIGN KEY ([ClientCompanyId]) REFERENCES [dbo].[ClientCompany] ([ClientCompanyId])
GO

ALTER TABLE [dbo].[UsersxClientCompany]
  ADD CONSTRAINT [FK_UsersxClientCompany_UserId] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([UserId])
GO