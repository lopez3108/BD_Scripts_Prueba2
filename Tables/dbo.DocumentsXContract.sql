CREATE TABLE [dbo].[DocumentsXContract] (
  [DocumentXContractID] [int] IDENTITY,
  [ContractId] [int] NOT NULL,
  [FileName] [varchar](255) NOT NULL,
  [UploadDate] [datetime] NULL,
  [LastUpdatedBy] [int] NULL,
  CONSTRAINT [PK_DocumentsXContract] PRIMARY KEY CLUSTERED ([DocumentXContractID])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[DocumentsXContract]
  ADD CONSTRAINT [FK_DocumentsXContract_Contract] FOREIGN KEY ([ContractId]) REFERENCES [dbo].[Contract] ([ContractId])
GO