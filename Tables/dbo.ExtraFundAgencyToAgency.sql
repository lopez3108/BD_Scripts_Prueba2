CREATE TABLE [dbo].[ExtraFundAgencyToAgency] (
  [ExtraFundAgencyToAgencyId] [int] IDENTITY,
  [FromAgencyId] [int] NOT NULL,
  [ToAgencyId] [int] NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [AssignedTo] [int] NOT NULL,
  [AcceptedBy] [int] NULL,
  [AcceptedDate] [datetime] NULL,
  [LastUpdatedBy] [int] NULL,
  [LastUpdatedOn] [datetime] NULL,
  CONSTRAINT [PK_ExtraFundAgencyToAgency] PRIMARY KEY CLUSTERED ([ExtraFundAgencyToAgencyId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[ExtraFundAgencyToAgency]
  ADD FOREIGN KEY ([AcceptedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[ExtraFundAgencyToAgency]
  ADD FOREIGN KEY ([AssignedTo]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[ExtraFundAgencyToAgency]
  ADD FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[ExtraFundAgencyToAgency]
  ADD FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[ExtraFundAgencyToAgency]
  ADD FOREIGN KEY ([FromAgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[ExtraFundAgencyToAgency]
  ADD FOREIGN KEY ([LastUpdatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[ExtraFundAgencyToAgency]
  ADD FOREIGN KEY ([ToAgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO