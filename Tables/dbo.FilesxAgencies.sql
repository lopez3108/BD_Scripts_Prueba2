CREATE TABLE [dbo].[FilesxAgencies] (
  [FilesxAgenciesId] [int] IDENTITY,
  [AgencyId] [int] NOT NULL,
  [CreationDate] [datetime] NULL,
  [UserId] [int] NULL,
  [Name] [varchar](150) NULL,
  [Extension] [varchar](25) NULL,
  [Base64] [varchar](max) NULL,
  [Window] [int] NULL,
  [Section] [int] NULL,
  PRIMARY KEY CLUSTERED ([FilesxAgenciesId])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[FilesxAgencies]
  ADD FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[FilesxAgencies]
  ADD CONSTRAINT [FK__FilesxAge__UserI__15A5FF8A] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([UserId])
GO