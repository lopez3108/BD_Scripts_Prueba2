CREATE TABLE [dbo].[TipoPersona] (
  [Codigo] [int] IDENTITY,
  [Telefono] [varchar](20) NOT NULL,
  [Mensaje] [varchar](50) NOT NULL,
  [TipoPersona] [bit] NOT NULL CONSTRAINT [DF_TipoPersona] DEFAULT (0),
  [ProviderId] [int] NOT NULL
)
ON [PRIMARY]
GO