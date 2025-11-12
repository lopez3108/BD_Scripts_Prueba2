CREATE TABLE [dbo].[ContactsXDirectory] (
  [ContactsXDirectoryId] [int] IDENTITY,
  [DirectoryId] [int] NOT NULL,
  [Email] [varchar](100) NOT NULL,
  [ContactName] [varchar](50) NOT NULL,
  [Extension] [varchar](5) NULL,
  [Telephone] [varchar](12) NOT NULL,
  CONSTRAINT [ContactsXDirectory_pk] PRIMARY KEY NONCLUSTERED ([ContactsXDirectoryId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[ContactsXDirectory]
  ADD CONSTRAINT [ContactsXDirectory_Directory_DirectoryId_fk] FOREIGN KEY ([DirectoryId]) REFERENCES [dbo].[Directory] ([DirectoryId])
GO