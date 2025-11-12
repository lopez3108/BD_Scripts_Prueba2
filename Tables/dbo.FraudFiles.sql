CREATE TABLE [dbo].[FraudFiles] (
  [FraudDocumentId] [int] IDENTITY,
  [FraudId] [int] NULL,
  [Name] [varchar](100) NULL,
  [CreationDate] [datetime] NULL,
  CONSTRAINT [PK_FraudFiles_FraudDocumentId] PRIMARY KEY CLUSTERED ([FraudDocumentId])
)
ON [PRIMARY]
GO