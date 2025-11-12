CREATE TABLE [dbo].[ExpensesType] (
  [ExpensesTypeId] [int] IDENTITY,
  [Code] [varchar](4) NOT NULL,
  [Description] [nvarchar](50) NOT NULL,
  CONSTRAINT [PK_ExpensesType] PRIMARY KEY CLUSTERED ([ExpensesTypeId]),
  CONSTRAINT [IX_ExpensesType] UNIQUE ([Code])
)
ON [PRIMARY]
GO