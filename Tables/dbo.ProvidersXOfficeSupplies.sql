CREATE TABLE [dbo].[ProvidersXOfficeSupplies] (
  [ProvidersXOfficeSuppliesId] [int] IDENTITY,
  [OfficeSupplieId] [int] NOT NULL,
  [ProvidersOfficeSuppliesId] [int] NOT NULL,
  CONSTRAINT [PK_ProvidersXOfficeSupplies] PRIMARY KEY CLUSTERED ([ProvidersXOfficeSuppliesId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[ProvidersXOfficeSupplies]
  ADD CONSTRAINT [FK_ProvidersXOfficeSupplies_OfficeSupplies] FOREIGN KEY ([OfficeSupplieId]) REFERENCES [dbo].[OfficeSupplies] ([OfficeSupplieId])
GO

ALTER TABLE [dbo].[ProvidersXOfficeSupplies]
  ADD CONSTRAINT [FK_ProvidersXOfficeSupplies_ProvidersOfficeSupplies] FOREIGN KEY ([ProvidersOfficeSuppliesId]) REFERENCES [dbo].[ProvidersOfficeSupplies] ([ProvidersOfficeSuppliesId])
GO