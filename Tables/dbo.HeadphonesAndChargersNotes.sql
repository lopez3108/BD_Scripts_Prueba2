CREATE TABLE [dbo].[HeadphonesAndChargersNotes] (
  [NotesXHeadphonesAndChargersId] [int] IDENTITY,
  [HeadphonesAndChargerId] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [ValidatedBy] [int] NOT NULL,
  [Note] [varchar](400) NOT NULL,
  [AgencyId] [int] NOT NULL,
  CONSTRAINT [PK_HeadphonesAndChargersNotes_1] PRIMARY KEY CLUSTERED ([NotesXHeadphonesAndChargersId])
)
ON [PRIMARY]
GO