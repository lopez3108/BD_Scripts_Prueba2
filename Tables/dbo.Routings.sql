CREATE TABLE [dbo].[Routings] (
  [RoutingId] [int] IDENTITY,
  [Number] [varchar](15) NOT NULL,
  [BankName] [varchar](60) NULL,
  [BankPhone] [varchar](15) NULL,
  CONSTRAINT [PK__Routings__A763F888CDF43925] PRIMARY KEY CLUSTERED ([RoutingId])
)
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'No se puede cambiar el numero de routing, crear un registro con el nuevo numero.', 'SCHEMA', N'dbo', 'TABLE', N'Routings'
GO