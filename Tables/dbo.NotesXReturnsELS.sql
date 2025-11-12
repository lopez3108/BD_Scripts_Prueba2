CREATE TABLE [dbo].[NotesXReturnsELS] (
  [NotesXReturnsELSId] [int] IDENTITY,
  [CreatedBy] [int] NOT NULL,
  [Note] [varchar](2000) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [ReturnsELSId] [int] NOT NULL,
  PRIMARY KEY CLUSTERED ([NotesXReturnsELSId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[NotesXReturnsELS]
  ADD CONSTRAINT [FK_NotesXReturnsELS_CreatedBy] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[NotesXReturnsELS]
  ADD CONSTRAINT [FK_NotesXReturnsELS_ReturnsELS] FOREIGN KEY ([ReturnsELSId]) REFERENCES [dbo].[ReturnsELS] ([ReturnsELSId])
GO