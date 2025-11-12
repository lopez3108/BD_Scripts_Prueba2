CREATE TABLE [dbo].[Msb] (
  [MsbId] [int] IDENTITY,
  [CreationDate] [datetime] NOT NULL,
  [ExpirationDate] [datetime] NOT NULL,
  [DocumentName] [varchar](50) NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [LastUpdatedOn] [datetime] NOT NULL,
  [LastUpdatedBy] [int] NOT NULL,
  CONSTRAINT [PK_Msb] PRIMARY KEY CLUSTERED ([MsbId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[Msb]
  ADD CONSTRAINT [FK_Msb_CreatedBy] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[Msb]
  ADD CONSTRAINT [FK_Msb_LastUpdatedBy] FOREIGN KEY ([LastUpdatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO