CREATE TABLE [dbo].[Irs] (
  [IrsId] [int] IDENTITY,
  [AgencyId] [int] NOT NULL,
  [CreationDate] [datetime] NULL,
  [UserId] [int] NULL,
  [Name] [varchar](150) NULL,
  [Extension] [varchar](25) NULL,
  [Base64] [varchar](max) NULL,
  [Window] [int] NULL,
  PRIMARY KEY CLUSTERED ([IrsId])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Irs]
  ADD FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[Irs]
  ADD CONSTRAINT [FK__Irs__UserId__3B969E48] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([UserId])
GO