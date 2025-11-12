CREATE TABLE [dbo].[ContractFiles] (
  [ContractFileId] [int] IDENTITY,
  [ContractId] [int] NOT NULL,
  [TenantId] [int] NULL,
  [FileName] [varchar](255) NULL,
  [FileType] [varchar](50) NULL,
  [UploadDate] [datetime] NULL,
  [LastUpdatedBy] [int] NULL,
  CONSTRAINT [PK_ContractFiles] PRIMARY KEY CLUSTERED ([ContractFileId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[ContractFiles]
  ADD CONSTRAINT [FK_ContractFiles_Contract] FOREIGN KEY ([ContractId]) REFERENCES [dbo].[Contract] ([ContractId])
GO

ALTER TABLE [dbo].[ContractFiles]
  ADD CONSTRAINT [FK_ContractFiles_Tenants] FOREIGN KEY ([TenantId]) REFERENCES [dbo].[Tenants] ([TenantId])
GO