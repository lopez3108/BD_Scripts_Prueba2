CREATE TABLE [dbo].[Months] (
  [MonthId] [int] IDENTITY,
  [Number] [int] NOT NULL,
  [Description] [varchar](20) NOT NULL,
  CONSTRAINT [PK_Months] PRIMARY KEY CLUSTERED ([MonthId])
)
ON [PRIMARY]
GO