CREATE TABLE [dbo].[TicketStatus] (
  [TicketStatusId] [int] IDENTITY,
  [Description] [varchar](30) NOT NULL,
  [Code] [varchar](10) NOT NULL,
  [Sort] [int] NULL,
  CONSTRAINT [PK_TicketStatus] PRIMARY KEY CLUSTERED ([TicketStatusId])
)
ON [PRIMARY]
GO