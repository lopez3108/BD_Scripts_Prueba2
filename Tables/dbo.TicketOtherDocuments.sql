CREATE TABLE [dbo].[TicketOtherDocuments] (
  [DocumentId] [int] IDENTITY,
  [TicketId] [int] NOT NULL,
  [FileNameOthers] [varchar](255) NOT NULL,
  CONSTRAINT [PK_TicketOtherDocuments] PRIMARY KEY CLUSTERED ([DocumentId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[TicketOtherDocuments]
  ADD CONSTRAINT [FK_TicketOtherDocuments_Tickets] FOREIGN KEY ([TicketId]) REFERENCES [dbo].[Tickets] ([TicketId])
GO