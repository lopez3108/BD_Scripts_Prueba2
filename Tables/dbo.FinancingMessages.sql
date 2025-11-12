CREATE TABLE [dbo].[FinancingMessages] (
  [FinancingMessageId] [int] IDENTITY,
  [Title] [varchar](50) NOT NULL,
  [Message] [varchar](500) NOT NULL,
  [SMSCategoryId] [int] NOT NULL,
  CONSTRAINT [PK_FinancingMessages] PRIMARY KEY CLUSTERED ([FinancingMessageId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[FinancingMessages] WITH NOCHECK
  ADD CONSTRAINT [FK_FinancingMessages_SMSCategories] FOREIGN KEY ([SMSCategoryId]) REFERENCES [dbo].[SMSCategories] ([SMSCategoryId])
GO