CREATE TABLE [dbo].[ProvidersOfficeSupplies] (
  [ProvidersOfficeSuppliesId] [int] IDENTITY,
  [ProviderName] [varchar](50) NOT NULL,
  CONSTRAINT [PK_ProvidersOfficeSupplies] PRIMARY KEY CLUSTERED ([ProvidersOfficeSuppliesId])
)
ON [PRIMARY]
GO

CREATE UNIQUE INDEX [IX_unique_ProviderName]
  ON [dbo].[ProvidersOfficeSupplies] ([ProviderName])
  ON [PRIMARY]
GO