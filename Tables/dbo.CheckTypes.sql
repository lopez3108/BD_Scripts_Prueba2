CREATE TABLE [dbo].[CheckTypes] (
  [CheckTypeId] [int] IDENTITY,
  [Description] [varchar](50) NOT NULL,
  [DefaultFee] [decimal](18, 2) NOT NULL CONSTRAINT [DF_CheckTypes_DefaultFee] DEFAULT (0),
  [Active] [bit] NOT NULL CONSTRAINT [DF__CheckType__Activ__4456017B] DEFAULT (1),
  [MaxCheckAmount] [decimal](18, 2) NOT NULL CONSTRAINT [DF_CheckTypes_MaxCheckAmount] DEFAULT (0),
  [CategoryCheckTypeId] [int] NULL,
  CONSTRAINT [PK_CheckTypes] PRIMARY KEY CLUSTERED ([CheckTypeId])
)
ON [PRIMARY]
GO

CREATE UNIQUE INDEX [IX_DataNonRepeatDescription]
  ON [dbo].[CheckTypes] ([Description])
  ON [PRIMARY]
GO