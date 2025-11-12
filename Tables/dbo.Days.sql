CREATE TABLE [dbo].[Days] (
  [DayId] [int] IDENTITY,
  [Code] [varchar](20) NOT NULL,
  [Description] [varchar](20) NOT NULL,
  [LabelTranslate] [varchar](30) NULL,
  CONSTRAINT [PK_Days] PRIMARY KEY CLUSTERED ([DayId])
)
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Dias semana', 'SCHEMA', N'dbo', 'TABLE', N'Days'
GO