CREATE TABLE [dbo].[CardBanks] (
  [CardBankId] [int] IDENTITY,
  [CardNumber] [varchar](4) NOT NULL,
  [Active] [bit] NOT NULL DEFAULT (1),
  [CreatedBy] [int] NULL,
  [CreationDate] [datetime] NULL,
  PRIMARY KEY CLUSTERED ([CardBankId])
)
ON [PRIMARY]
GO