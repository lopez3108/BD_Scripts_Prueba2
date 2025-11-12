CREATE TABLE [dbo].[InsuranceQuoteNote] (
  [InsuranceQuoteNoteId] [int] IDENTITY,
  [InsuranceQuoteId] [int] NOT NULL,
  [Note] [varchar](2000) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NULL,
  CONSTRAINT [PK_InsuranceQuotNote] PRIMARY KEY CLUSTERED ([InsuranceQuoteNoteId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[InsuranceQuoteNote]
  ADD CONSTRAINT [FK_InsuranceQuotNote_InsuranceQuot] FOREIGN KEY ([InsuranceQuoteId]) REFERENCES [dbo].[InsuranceQuote] ([InsuranceQuoteId])
GO

ALTER TABLE [dbo].[InsuranceQuoteNote]
  ADD CONSTRAINT [FK_InsuranceQuotNote_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO