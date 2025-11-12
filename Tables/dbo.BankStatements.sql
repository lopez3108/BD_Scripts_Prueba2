CREATE TABLE [dbo].[BankStatements] (
  [BankStatementsId] [int] IDENTITY,
  [Year] [int] NOT NULL,
  [Month] [int] NOT NULL,
  [Agencies] [varchar](100) NOT NULL,
  [Bank] [int] NOT NULL,
  [Account] [int] NOT NULL,
  [CreationDate] [datetime] NULL,
  [UserId] [int] NULL,
  [Name] [varchar](150) NULL,
  [Extension] [varchar](25) NULL,
  [Base64] [varchar](max) NULL,
  PRIMARY KEY CLUSTERED ([BankStatementsId])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[BankStatements]
  ADD CONSTRAINT [FK__BankState__UserI__1AF4C48C] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[BankStatements]
  ADD CONSTRAINT [FK_BankStatements_Account] FOREIGN KEY ([Account]) REFERENCES [dbo].[BankAccounts] ([BankAccountId])
GO

ALTER TABLE [dbo].[BankStatements]
  ADD CONSTRAINT [FK_BankStatements_Bank] FOREIGN KEY ([Bank]) REFERENCES [dbo].[Bank] ([BankId])
GO