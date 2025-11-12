CREATE TABLE [dbo].[Ventra] (
  [VentraId] [int] IDENTITY,
  [ReloadQuantity] [int] NOT NULL,
  [ReloadUsd] [decimal](18, 2) NOT NULL,
  [Commission] [decimal](18, 2) NOT NULL CONSTRAINT [DF_Ventra_Commission] DEFAULT (0),
  [CreatedBy] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [LastUpdatedOn] [datetime] NULL,
  [LastUpdatedBy] [int] NULL,
  CONSTRAINT [PK_Ventra] PRIMARY KEY CLUSTERED ([VentraId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[Ventra]
  ADD CONSTRAINT [FK_Ventra_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[Ventra]
  ADD CONSTRAINT [FK_Ventra_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO