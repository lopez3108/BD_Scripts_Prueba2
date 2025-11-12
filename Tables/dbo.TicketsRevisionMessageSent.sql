CREATE TABLE [dbo].[TicketsRevisionMessageSent] (
  [TicketsRevisionMessageSentId] [int] IDENTITY,
  [Telephone] [varchar](10) NOT NULL,
  [LastMessageSentDate] [datetime] NOT NULL,
  CONSTRAINT [PK_TicketsRevisionMessageSent] PRIMARY KEY CLUSTERED ([TicketsRevisionMessageSentId])
)
ON [PRIMARY]
GO