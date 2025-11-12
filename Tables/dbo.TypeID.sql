CREATE TABLE [dbo].[TypeID] (
  [TypeId] [int] IDENTITY,
  [Description] [varchar](30) NOT NULL,
  CONSTRAINT [PK_TypeID] PRIMARY KEY CLUSTERED ([TypeId])
)
ON [PRIMARY]
GO

CREATE UNIQUE INDEX [IX_Description_Type]
  ON [dbo].[TypeID] ([Description])
  ON [PRIMARY]
GO