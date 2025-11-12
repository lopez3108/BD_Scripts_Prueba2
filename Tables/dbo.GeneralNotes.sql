CREATE TABLE [dbo].[GeneralNotes] (
  [GeneralNoteId] [int] IDENTITY,
  [Description] [varchar](2000) NOT NULL,
  [GeneralNotesStatusId] [int] NOT NULL,
  [ProviderId] [int] NOT NULL,
  [ClientName] [varchar](150) NOT NULL,
  [ClientTelephone] [varchar](10) NOT NULL,
  [TransactionNumber] [varchar](30) NOT NULL,
  [OtherDescription] [varchar](80) NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [ClosedBy] [int] NULL,
  [ClosedOn] [datetime] NULL,
  [TelIsCheck] [bit] NULL,
  [FileGeneralNotes] [varchar](200) NULL,
  CONSTRAINT [PK_GeneralNotes] PRIMARY KEY CLUSTERED ([GeneralNoteId])
)
ON [PRIMARY]
GO

CREATE UNIQUE INDEX [IX_Transaction_Number_Provider]
  ON [dbo].[GeneralNotes] ([TransactionNumber], [ProviderId])
  ON [PRIMARY]
GO

ALTER TABLE [dbo].[GeneralNotes]
  ADD CONSTRAINT [FK_GeneralNotes_ProviderId] FOREIGN KEY ([ProviderId]) REFERENCES [dbo].[Providers] ([ProviderId])
GO