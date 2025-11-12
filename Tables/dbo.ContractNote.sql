CREATE TABLE [dbo].[ContractNote] (
  [ContractNoteId] [int] IDENTITY,
  [Note] [varchar](500) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [ContractId] [int] NOT NULL
)
ON [PRIMARY]
GO