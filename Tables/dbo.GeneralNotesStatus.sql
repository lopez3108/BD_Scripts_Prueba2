CREATE TABLE [dbo].[GeneralNotesStatus] (
  [GeneralNotesStatusId] [int] IDENTITY,
  [Code] [varchar](3) NOT NULL,
  [Description] [varchar](50) NOT NULL,
  CONSTRAINT [PK_GeneralNotesStatus] PRIMARY KEY CLUSTERED ([GeneralNotesStatusId])
)
ON [PRIMARY]
GO