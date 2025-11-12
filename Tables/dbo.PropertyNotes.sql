CREATE TABLE [dbo].[PropertyNotes] (
  [PropertyNotesId] [int] IDENTITY,
  [PropertiesId] [int] NOT NULL,
  [Note] [varchar](300) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  CONSTRAINT [PK_PropertyNotes] PRIMARY KEY CLUSTERED ([PropertyNotesId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[PropertyNotes]
  ADD CONSTRAINT [FKPropertyNotes_Properties] FOREIGN KEY ([PropertiesId]) REFERENCES [dbo].[Properties] ([PropertiesId])
GO