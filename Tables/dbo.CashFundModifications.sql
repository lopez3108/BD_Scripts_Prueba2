CREATE TABLE [dbo].[CashFundModifications] (
  [CashFundModificationsId] [int] IDENTITY,
  [CashierId] [int] NOT NULL,
  [CreditCashFund] [decimal](18, 2) NOT NULL,
  [DebitCashFund] [decimal](18, 2) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [IsReturned] [bit] NOT NULL CONSTRAINT [DF_CashFundModifications_FirstCashFund] DEFAULT (0),
  CONSTRAINT [PK__CashFund__6FBE3026BC790B54] PRIMARY KEY CLUSTERED ([CashFundModificationsId])
)
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Cada vez que se le da cash fund  a un cajero se suma en este campo', 'SCHEMA', N'dbo', 'TABLE', N'CashFundModifications', 'COLUMN', N'CreditCashFund'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Cada vez que se le retira cash fund  a un cajero se suma en este campo', 'SCHEMA', N'dbo', 'TABLE', N'CashFundModifications', 'COLUMN', N'DebitCashFund'
GO