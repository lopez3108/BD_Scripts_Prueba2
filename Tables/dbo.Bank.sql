CREATE TABLE [dbo].[Bank] (
  [BankId] [int] IDENTITY,
  [Name] [varchar](50) NOT NULL,
  [Telephone] [varchar](10) NULL,
  [ContactName] [varchar](50) NULL,
  CONSTRAINT [PK_Bank] PRIMARY KEY CLUSTERED ([BankId])
)
ON [PRIMARY]
GO

CREATE UNIQUE INDEX [IX_Bank]
  ON [dbo].[Bank] ([Name])
  ON [PRIMARY]
GO