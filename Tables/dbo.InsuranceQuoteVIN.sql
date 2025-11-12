CREATE TABLE [dbo].[InsuranceQuoteVIN] (
  [InsuranceQuoteVINId] [int] IDENTITY,
  [InsuranceQuoteId] [int] NOT NULL,
  [VINNumber] [varchar](30) NOT NULL,
  CONSTRAINT [PK_InsuranceQuotVIN] PRIMARY KEY CLUSTERED ([InsuranceQuoteVINId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[InsuranceQuoteVIN]
  ADD CONSTRAINT [FK_InsuranceQuotVIN_InsuranceQuot] FOREIGN KEY ([InsuranceQuoteId]) REFERENCES [dbo].[InsuranceQuote] ([InsuranceQuoteId])
GO