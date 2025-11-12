CREATE TABLE [dbo].[AgenciesXOrdersSupplies] (
  [AgenciesXOrdersSuppliesId] [int] IDENTITY,
  [OrderOfficeSupplieId] [int] NOT NULL,
  [AgencyId] [int] NOT NULL,
  CONSTRAINT [PK_AgenciesXOrdersSupplies] PRIMARY KEY CLUSTERED ([AgenciesXOrdersSuppliesId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[AgenciesXOrdersSupplies]
  ADD CONSTRAINT [FK_AgenciesXOrdersSupplies_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO