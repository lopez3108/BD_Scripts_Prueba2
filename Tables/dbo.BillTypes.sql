CREATE TABLE [dbo].[BillTypes] (
  [BillTypeId] [int] IDENTITY,
  [Description] [varchar](20) NOT NULL,
  CONSTRAINT [PK_BillTypes] PRIMARY KEY CLUSTERED ([BillTypeId]),
  CONSTRAINT [IX_BillTypes] UNIQUE ([Description])
)
ON [PRIMARY]
GO