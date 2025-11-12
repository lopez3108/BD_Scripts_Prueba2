CREATE TABLE [dbo].[ProviderTrainingAuditing] (
  [ProviderTrainingAuditingId] [int] IDENTITY,
  [AgencyId] [int] NOT NULL,
  [ProviderId] [int] NOT NULL,
  [CreationDate] [datetime] NULL,
  [UserId] [int] NULL,
  [Name] [varchar](150) NULL,
  [Extension] [varchar](25) NULL,
  [Base64] [varchar](max) NULL,
  [Window] [int] NULL,
  PRIMARY KEY CLUSTERED ([ProviderTrainingAuditingId])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[ProviderTrainingAuditing]
  ADD FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[ProviderTrainingAuditing]
  ADD CONSTRAINT [FK__ProviderT__Provi__247341CE] FOREIGN KEY ([ProviderId]) REFERENCES [dbo].[Providers] ([ProviderId])
GO

ALTER TABLE [dbo].[ProviderTrainingAuditing]
  ADD CONSTRAINT [FK__ProviderT__UserI__5FD3FEBE] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([UserId])
GO