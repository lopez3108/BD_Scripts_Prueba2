CREATE TABLE [dbo].[SystemToolsValues] (
  [BillxBillValueId] [int] IDENTITY,
  [BillId] [int] NOT NULL,
  [Value] [decimal](18, 2) NOT NULL CONSTRAINT [DF_SystemToolsValues_Value] DEFAULT (0),
  [Fee] [decimal](18, 2) NOT NULL,
  CONSTRAINT [PK_SystemToolsValues] PRIMARY KEY CLUSTERED ([BillxBillValueId])
)
ON [PRIMARY]
GO