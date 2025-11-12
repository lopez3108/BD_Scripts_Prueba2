CREATE TABLE [dbo].[TicketPaymentTypes] (
  [TicketPaymentTypeId] [int] IDENTITY,
  [Code] [varchar](10) NOT NULL,
  [Description] [varchar](25) NOT NULL,
  CONSTRAINT [PK_TicketPaymentTypes] PRIMARY KEY CLUSTERED ([TicketPaymentTypeId])
)
ON [PRIMARY]
GO