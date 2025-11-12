CREATE TABLE [dbo].[ChangeTypeStatus] (
  [ChangeTypeId] [int] IDENTITY,
  [Code] [varchar](3) NOT NULL,
  [Description] [varchar](30) NOT NULL,
  CONSTRAINT [PK_ChangeTypeStatus] PRIMARY KEY CLUSTERED ([ChangeTypeId])
)
ON [PRIMARY]
GO