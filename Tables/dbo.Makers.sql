CREATE TABLE [dbo].[Makers] (
  [MakerId] [int] IDENTITY,
  [Name] [varchar](80) NOT NULL,
  [FileNumber] [varchar](12) NULL,
  [EntityTypeId] [int] NULL,
  [IncorporationDate] [datetime] NULL,
  [UpdatedBy] [int] NULL,
  [UpdatedOn] [datetime] NULL,
  [AgencyId] [int] NULL,
  [CreatedBy] [int] NOT NULL,
  [ValidatedBy] [int] NULL,
  [OtherStateId] [int] NULL,
  [NoRegistered] [bit] NULL,
  [CreationDate] [datetime] NULL,
  [ValidatedMakerBy] [int] NULL,
  [ValidatedMakerOn] [datetime] NULL,
  CONSTRAINT [PK_Makers] PRIMARY KEY CLUSTERED ([MakerId]),
  CONSTRAINT [IX_Makers_Name] UNIQUE ([Name])
)
ON [PRIMARY]
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE UNIQUE INDEX [IX_Makers_FileNumber]
  ON [dbo].[Makers] ([FileNumber])
  WHERE ([FileNumber] IS NOT NULL)
  ON [PRIMARY]
GO

ALTER TABLE [dbo].[Makers]
  ADD CONSTRAINT [FK_Makers_CreatedBy] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[Makers]
  ADD CONSTRAINT [FK_Makers_UpdatedBy] FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[Makers]
  ADD CONSTRAINT [FK_Makers_Users] FOREIGN KEY ([ValidatedMakerBy]) REFERENCES [dbo].[Users] ([UserId])
GO