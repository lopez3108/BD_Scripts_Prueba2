CREATE TABLE [dbo].[RunnerServices] (
  [RunnerServiceId] [int] IDENTITY,
  [NumberTransactions] [int] NOT NULL,
  [USD] [decimal](18, 2) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [FeeEls] [decimal](18, 2) NULL CONSTRAINT [DF_RunnerServices_FeeEls] DEFAULT (0),
  CONSTRAINT [PK_RunnerServices] PRIMARY KEY CLUSTERED ([RunnerServiceId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[RunnerServices]
  ADD CONSTRAINT [FK_RunnerServices_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[RunnerServices]
  ADD CONSTRAINT [FK_RunnerServices_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO