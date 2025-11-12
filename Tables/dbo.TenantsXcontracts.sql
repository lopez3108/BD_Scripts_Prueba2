CREATE TABLE [dbo].[TenantsXcontracts] (
  [TenantsXcontractId] [int] IDENTITY,
  [TenantId] [int] NULL,
  [ContractId] [int] NULL,
  [Principal] [bit] NULL,
  CONSTRAINT [PK_TenantsXcontracts] PRIMARY KEY CLUSTERED ([TenantsXcontractId])
)
ON [PRIMARY]
GO

CREATE UNIQUE INDEX [IX_TenantsXcontracts]
  ON [dbo].[TenantsXcontracts] ([TenantId], [ContractId])
  ON [PRIMARY]
GO

ALTER TABLE [dbo].[TenantsXcontracts]
  ADD CONSTRAINT [FK_TenantsXcontracts_ContractId] FOREIGN KEY ([ContractId]) REFERENCES [dbo].[Contract] ([ContractId])
GO

ALTER TABLE [dbo].[TenantsXcontracts]
  ADD CONSTRAINT [FK_TenantsXcontracts_TenantId] FOREIGN KEY ([TenantId]) REFERENCES [dbo].[Tenants] ([TenantId])
GO