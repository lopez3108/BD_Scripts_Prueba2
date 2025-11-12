CREATE TABLE [dbo].[TermsXContract] (
  [TermsXContractId] [int] IDENTITY,
  [Terms] [varchar](3000) NOT NULL,
  [ContractId] [int] NOT NULL,
  CONSTRAINT [PK_TermsXContracts] PRIMARY KEY CLUSTERED ([TermsXContractId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[TermsXContract]
  ADD CONSTRAINT [FK_TermsXContracts_Contract] FOREIGN KEY ([ContractId]) REFERENCES [dbo].[Contract] ([ContractId])
GO