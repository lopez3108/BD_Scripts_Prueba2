CREATE TABLE [dbo].[RegisteredMacs] (
  [RegisteredMacId] [int] IDENTITY,
  [Mac] [varchar](30) NOT NULL,
  [Description] [varchar](30) NOT NULL,
  [ComputerBrand] [varchar](30) NULL,
  [CreatedBy] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [AgencyId] [int] NULL,
  CONSTRAINT [PK_RegisteredMacs] PRIMARY KEY CLUSTERED ([RegisteredMacId]),
  CONSTRAINT [IX_RegisteredMacs] UNIQUE ([Mac])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[RegisteredMacs]
  ADD CONSTRAINT [FK_RegisteredMacs_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[RegisteredMacs]
  ADD CONSTRAINT [FK_RegisteredMacs_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO