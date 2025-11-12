CREATE TABLE [dbo].[PayrollOtherTypes] (
  [PayrollOtherTypesId] [int] IDENTITY,
  [Description] [varchar](15) NOT NULL,
  CONSTRAINT [PK_PayrollOtherTypes] PRIMARY KEY CLUSTERED ([PayrollOtherTypesId])
)
ON [PRIMARY]
GO