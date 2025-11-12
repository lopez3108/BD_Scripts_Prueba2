CREATE TABLE [dbo].[PublishExchangeRates] (
  [PublishExchangeRateId] [int] IDENTITY,
  [CreationDate] [datetime] NOT NULL,
  [PublishBy] [int] NOT NULL,
  [Value] [decimal](18, 2) NULL,
  CONSTRAINT [PK_PublishExchangeRates] PRIMARY KEY CLUSTERED ([PublishExchangeRateId])
)
ON [PRIMARY]
GO