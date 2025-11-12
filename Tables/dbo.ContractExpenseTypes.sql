CREATE TABLE [dbo].[ContractExpenseTypes] (
  [ContractExpenseTypeId] [int] IDENTITY,
  [Description] [varchar](50) NOT NULL,
  [DefaultUsd] [decimal] NULL
)
ON [PRIMARY]
GO