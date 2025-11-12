CREATE TABLE [dbo].[MaritalStatus] (
  [MaritalStatusId] [int] IDENTITY,
  [Description] [varchar](30) NOT NULL,
  [Code] [varchar](4) NOT NULL,
  CONSTRAINT [PK_MaritalStatus] PRIMARY KEY CLUSTERED ([MaritalStatusId])
)
ON [PRIMARY]
GO