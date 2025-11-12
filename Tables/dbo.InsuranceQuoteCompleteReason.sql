CREATE TABLE [dbo].[InsuranceQuoteCompleteReason] (
  [InsuranceQuoteCompleteReasonId] [int] IDENTITY,
  [Description] [varchar](200) NOT NULL,
  [Code] [varchar](4) NOT NULL,
  CONSTRAINT [PK_InsuranceQuodCompleteReason] PRIMARY KEY CLUSTERED ([InsuranceQuoteCompleteReasonId])
)
ON [PRIMARY]
GO