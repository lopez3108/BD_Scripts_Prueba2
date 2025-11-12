CREATE TABLE [dbo].[CheckFraudTypes] (
  [CheckTypeId] [int] IDENTITY,
  [Description] [varchar](50) NOT NULL,
  [CategoryCheckTypeId] [int] NOT NULL
)
ON [PRIMARY]
GO