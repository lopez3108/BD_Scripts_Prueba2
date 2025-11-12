CREATE TABLE [dbo].[CheckFraudExceptions] (
  [CheckFraudExceptionId] [int] IDENTITY,
  [Account] [varchar](50) NOT NULL,
  [IsSafe] [bit] NOT NULL,
  [Maker] [varchar](80) NULL,
  [IsNotFraud] [bit] NULL,
  CONSTRAINT [PK_CheckFraudExceptions] PRIMARY KEY CLUSTERED ([CheckFraudExceptionId]),
  CONSTRAINT [IX_CheckFraudExceptions_Account_Maker] UNIQUE ([Account], [Maker])
)
ON [PRIMARY]
GO