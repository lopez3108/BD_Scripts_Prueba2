CREATE TABLE [dbo].[ContractNotes] (
  [ContractNotesId] [int] IDENTITY,
  [ContractId] [int] NOT NULL,
  [Note] [varchar](300) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  CONSTRAINT [PK_ContractNotes] PRIMARY KEY CLUSTERED ([ContractNotesId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[ContractNotes]
  ADD CONSTRAINT [FKContractNotes_Contract] FOREIGN KEY ([ContractId]) REFERENCES [dbo].[Contract] ([ContractId])
GO