CREATE TABLE [dbo].[ElsManualOther] (
  [OtherId] [int] IDENTITY,
  [TitleId] [int] NOT NULL,
  [FileIdNameOther] [varchar](500) NOT NULL,
  CONSTRAINT [PK_ElsManualOther] PRIMARY KEY CLUSTERED ([OtherId])
)
ON [PRIMARY]
GO