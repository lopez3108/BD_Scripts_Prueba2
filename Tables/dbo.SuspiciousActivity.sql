CREATE TABLE [dbo].[SuspiciousActivity] (
  [SuspiciousActivityId] [int] IDENTITY,
  [ProviderId] [int] NOT NULL,
  [TransactionNumber] [varchar](20) NOT NULL,
  [USD] [decimal](18, 2) NOT NULL,
  [Note] [varchar](1000) NULL,
  [SAR] [bit] NULL CONSTRAINT [DF__SuspiciousA__SAR__25C758BA] DEFAULT (0),
  [AgencyId] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [SuspiciousActivityStatusId] [int] NOT NULL,
  CONSTRAINT [PK__Suspicio__53C21051A4A14DA0] PRIMARY KEY CLUSTERED ([SuspiciousActivityId])
)
ON [PRIMARY]
GO

CREATE UNIQUE INDEX [IX_Transaction_Number_Provider_Suspicious]
  ON [dbo].[SuspiciousActivity] ([TransactionNumber], [ProviderId])
  ON [PRIMARY]
GO

ALTER TABLE [dbo].[SuspiciousActivity]
  ADD CONSTRAINT [FK_SuspiciousActivity_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[SuspiciousActivity]
  ADD CONSTRAINT [FK_SuspiciousActivity_Providers] FOREIGN KEY ([ProviderId]) REFERENCES [dbo].[Providers] ([ProviderId])
GO

ALTER TABLE [dbo].[SuspiciousActivity]
  ADD CONSTRAINT [FK_SuspiciousActivity_SuspiciousActivityStatusId] FOREIGN KEY ([SuspiciousActivityStatusId]) REFERENCES [dbo].[SuspiciousActivityStatus] ([SuspiciousActivityStatusId])
GO

ALTER TABLE [dbo].[SuspiciousActivity]
  ADD CONSTRAINT [FK_SuspiciousActivity_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO