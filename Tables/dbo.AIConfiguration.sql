CREATE TABLE [dbo].[AIConfiguration] (
  [AIConfigurationId] [int] IDENTITY,
  [ClientPendingTicketMessage] [varchar](max) NOT NULL,
  CONSTRAINT [PK_AIConfiguration] PRIMARY KEY CLUSTERED ([AIConfigurationId])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO