CREATE TABLE [dbo].[CheckListVehicleServices] (
  [CheckListId] [int] IDENTITY,
  [Code] [varchar](3) NOT NULL,
  [LabelEN] [varchar](100) NOT NULL,
  [ProcessTrpId] [int] NULL,
  [ProviderElsId] [int] NULL,
  [LabelES] [varchar](100) NULL,
  CONSTRAINT [PK_CheckListVehicleServices_CheckListId] PRIMARY KEY CLUSTERED ([CheckListId])
)
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Contiene opciones de confirmacion para trp y titles', 'SCHEMA', N'dbo', 'TABLE', N'CheckListVehicleServices'
GO