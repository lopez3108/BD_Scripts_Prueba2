CREATE TABLE [dbo].[ApartmentNotes] (
  [ApartmentNotesId] [int] IDENTITY,
  [ApartmentId] [int] NOT NULL,
  [Note] [varchar](300) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  CONSTRAINT [PK_ApartmentNotes] PRIMARY KEY CLUSTERED ([ApartmentNotesId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[ApartmentNotes]
  ADD CONSTRAINT [FKApartmentNotes_Apartments] FOREIGN KEY ([ApartmentId]) REFERENCES [dbo].[Apartments] ([ApartmentsId])
GO