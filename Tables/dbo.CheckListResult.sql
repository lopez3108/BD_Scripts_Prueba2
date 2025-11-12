CREATE TABLE [dbo].[CheckListResult] (
  [CheckListResultId] [int] IDENTITY,
  [TitleId] [int] NULL,
  [TRPId] [int] NULL,
  [CreatedBy] [int] NULL,
  [CreationDate] [datetime] NULL,
  [CheckListId] [int] NULL,
  [LabelEN] [varchar](100) NULL,
  [LabelES] [varchar](100) NULL,
  CONSTRAINT [PK_CheckListResult_CheckListResultId] PRIMARY KEY CLUSTERED ([CheckListResultId])
)
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Resultados de documentos requeridos en trp y titles', 'SCHEMA', N'dbo', 'TABLE', N'CheckListResult'
GO