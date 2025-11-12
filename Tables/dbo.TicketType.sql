CREATE TABLE [dbo].[TicketType] (
  [TicketTypeId] [int] IDENTITY,
  [Code] [varchar](4) NOT NULL,
  [Description] [varchar](20) NOT NULL,
  CONSTRAINT [PK_TicketType] PRIMARY KEY CLUSTERED ([TicketTypeId])
)
ON [PRIMARY]
GO