CREATE TABLE [dbo].[OfficeSupplies] (
  [OfficeSupplieId] [int] IDENTITY,
  [Name] [varchar](100) NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [LastUpdatedBy] [int] NULL,
  [LastUpdatedOn] [datetime] NULL,
  [FileOfficeSupplies] [varchar](200) NULL,
  [IsActive] [bit] NULL,
  CONSTRAINT [PK_OfficeSupplies] PRIMARY KEY CLUSTERED ([OfficeSupplieId])
)
ON [PRIMARY]
GO

CREATE UNIQUE INDEX [IX_unique_Name]
  ON [dbo].[OfficeSupplies] ([Name])
  ON [PRIMARY]
GO

ALTER TABLE [dbo].[OfficeSupplies]
  ADD CONSTRAINT [FK_OfficeSupplies_OfficeSupplies] FOREIGN KEY ([OfficeSupplieId]) REFERENCES [dbo].[OfficeSupplies] ([OfficeSupplieId])
GO

ALTER TABLE [dbo].[OfficeSupplies]
  ADD CONSTRAINT [FK_OfficeSupplies_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[OfficeSupplies]
  ADD CONSTRAINT [FK_OfficeSupplies_Users1] FOREIGN KEY ([LastUpdatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO