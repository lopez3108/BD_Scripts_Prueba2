CREATE TABLE [dbo].[TrainingXUsers] (
  [TrainingXUserId] [int] IDENTITY,
  [TrainingId] [int] NOT NULL,
  [UserId] [int] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [SIgnName] [varchar](500) NOT NULL,
  [LastCompleteOn] [datetime] NOT NULL,
  [TrainerId] [int] NOT NULL,
  [ComplianceOfficerId] [int] NOT NULL,
  CONSTRAINT [PK_TrainingXUsers] PRIMARY KEY CLUSTERED ([TrainingXUserId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[TrainingXUsers]
  ADD CONSTRAINT [FK__TrainingX__Traininig] FOREIGN KEY ([TrainingId]) REFERENCES [dbo].[Training] ([TrainingId])
GO

ALTER TABLE [dbo].[TrainingXUsers]
  ADD CONSTRAINT [FK_TrainingXUsers_AgencyId] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[TrainingXUsers]
  ADD CONSTRAINT [FK_TrainingXUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[TrainingXUsers]
  ADD CONSTRAINT [FK_TrainingXUsers_Users] FOREIGN KEY ([TrainerId]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[TrainingXUsers]
  ADD CONSTRAINT [FK_TrainingXUsers_Users1] FOREIGN KEY ([ComplianceOfficerId]) REFERENCES [dbo].[Users] ([UserId])
GO