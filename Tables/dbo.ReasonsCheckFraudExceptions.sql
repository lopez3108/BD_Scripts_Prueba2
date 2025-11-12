CREATE TABLE [dbo].[ReasonsCheckFraudExceptions] (
  [ReasonCheckFraudExceptionId] [int] IDENTITY,
  [CheckFraudExceptionId] [int] NOT NULL,
  [Reason] [varchar](300) NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  CONSTRAINT [PK_ReasonsCheckFraudExceptions] PRIMARY KEY CLUSTERED ([ReasonCheckFraudExceptionId])
)
ON [PRIMARY]
GO