CREATE TABLE [dbo].[MidSerialsByAgency] (
  [MidSerialsByAgencyId] [int] IDENTITY,
  [AgencyId] [int] NOT NULL,
  [MidNumber] [varchar](20) NOT NULL,
  [CreatedOn] [datetime] NULL,
  [CreatedBy] [int] NULL,
  PRIMARY KEY CLUSTERED ([MidSerialsByAgencyId])
)
ON [PRIMARY]
GO

CREATE UNIQUE INDEX [IX_MidSerialsByAgency]
  ON [dbo].[MidSerialsByAgency] ([AgencyId], [MidNumber])
  ON [PRIMARY]
GO

ALTER TABLE [dbo].[MidSerialsByAgency]
  ADD CONSTRAINT [FK_MidSerialsByAgency_Agency] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO