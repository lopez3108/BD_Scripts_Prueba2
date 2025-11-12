CREATE TABLE [dbo].[BankAccounts] (
  [BankAccountId] [int] IDENTITY,
  [BankId] [int] NOT NULL,
  [AccountNumber] [varchar](4) NOT NULL,
  [Active] [bit] NOT NULL CONSTRAINT [DF__BankAccou__Activ__463E49ED] DEFAULT (1),
  [InitialBalance] [decimal](18, 2) NOT NULL CONSTRAINT [DF__BankAccou__Initi__7B5130AA] DEFAULT (0.00),
  [FullAccount] [varchar](15) NULL,
  [CreatedBy] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  CONSTRAINT [PK__BankAcco__4FC8E4A144DF4607] PRIMARY KEY CLUSTERED ([BankAccountId])
)
ON [PRIMARY]
GO