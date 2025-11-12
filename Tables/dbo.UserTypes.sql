CREATE TABLE [dbo].[UserTypes] (
  [UsertTypeId] [int] IDENTITY,
  [Desciption] [varchar](20) NOT NULL,
  [Code] [varchar](50) NULL,
  CONSTRAINT [PK_UserTypes] PRIMARY KEY CLUSTERED ([UsertTypeId])
)
ON [PRIMARY]
GO