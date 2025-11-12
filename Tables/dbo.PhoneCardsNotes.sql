CREATE TABLE [dbo].[PhoneCardsNotes] (
  [NotesXPhoneCardsId] [int] IDENTITY,
  [PhoneCardId] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [ValidatedBy] [int] NULL,
  [Note] [varchar](400) NOT NULL,
  [AgencyId] [int] NOT NULL,
  CONSTRAINT [PK_PhoneCardsNotes] PRIMARY KEY CLUSTERED ([NotesXPhoneCardsId])
)
ON [PRIMARY]
GO