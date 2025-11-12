CREATE TABLE [dbo].[Forex] (
  [ForexId] [int] IDENTITY,
  [AgencyId] [int] NOT NULL,
  [ProviderId] [int] NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [LastUpdatedBy] [int] NULL,
  [LastUpdatedOn] [datetime] NULL,
  [FromDate] [datetime] NOT NULL,
  [ToDate] [datetime] NOT NULL,
  CONSTRAINT [PK_Forex] PRIMARY KEY CLUSTERED ([ForexId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[Forex]
  ADD FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[Forex]
  ADD FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[Forex]
  ADD FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[Forex]
  ADD FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[Forex]
  ADD FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[Forex]
  ADD FOREIGN KEY ([LastUpdatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[Forex]
  ADD FOREIGN KEY ([LastUpdatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[Forex]
  ADD FOREIGN KEY ([ProviderId]) REFERENCES [dbo].[Providers] ([ProviderId])
GO

ALTER TABLE [dbo].[Forex]
  ADD FOREIGN KEY ([ProviderId]) REFERENCES [dbo].[Providers] ([ProviderId])
GO

ALTER TABLE [dbo].[Forex]
  ADD FOREIGN KEY ([ProviderId]) REFERENCES [dbo].[Providers] ([ProviderId])
GO