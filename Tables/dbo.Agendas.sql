CREATE TABLE [dbo].[Agendas] (
  [AgendaId] [int] IDENTITY,
  [AgendaStatusId] [int] NOT NULL,
  [Description] [varchar](100) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [FileIdNameAgendaCopy] [varchar](200) NULL,
  [DelegateTo] [int] NULL,
  [UpdateBy] [int] NULL,
  [UpdateOn] [datetime] NULL,
  [DelegateBy] [int] NULL,
  CONSTRAINT [PK_Agendas_AgendaId] PRIMARY KEY CLUSTERED ([AgendaId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[Agendas]
  ADD CONSTRAINT [FK_Agendas_Agendas] FOREIGN KEY ([DelegateBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[Agendas]
  ADD CONSTRAINT [FK_Agendas_AgendaStatusId] FOREIGN KEY ([AgendaStatusId]) REFERENCES [dbo].[AgendaStatus] ([AgendaStatusId])
GO

ALTER TABLE [dbo].[Agendas] WITH NOCHECK
  ADD CONSTRAINT [FK_Agendas_Users] FOREIGN KEY ([DelegateTo]) REFERENCES [dbo].[Users] ([UserId]) NOT FOR REPLICATION
GO

ALTER TABLE [dbo].[Agendas]
  NOCHECK CONSTRAINT [FK_Agendas_Users]
GO