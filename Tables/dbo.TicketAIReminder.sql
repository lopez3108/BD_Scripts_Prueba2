CREATE TABLE [dbo].[TicketAIReminder] (
  [TicketAIReminderId] [int] IDENTITY,
  [TicketNumber] [varchar](30) NOT NULL,
  [Telephone] [varchar](10) NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  [DateSent] [datetime] NOT NULL,
  [TicketTypeId] [int] NOT NULL,
  [SendStatus] [bit] NOT NULL,
  [ExceptionThrown] [varchar](500) NULL,
  CONSTRAINT [PK_TicketAIReminder] PRIMARY KEY CLUSTERED ([TicketAIReminderId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[TicketAIReminder]
  ADD CONSTRAINT [FK_TicketAIReminder_TicketType] FOREIGN KEY ([TicketTypeId]) REFERENCES [dbo].[TicketType] ([TicketTypeId])
GO