CREATE TABLE [dbo].[AgendaStatus] (
  [AgendaStatusId] [int] IDENTITY,
  [Name] [varchar](20) NOT NULL,
  [Code] [varchar](5) NOT NULL,
  CONSTRAINT [PK_AgendaStatus_AgendaStatusId] PRIMARY KEY CLUSTERED ([AgendaStatusId]),
  UNIQUE ([Name]),
  UNIQUE ([Code])
)
ON [PRIMARY]
GO