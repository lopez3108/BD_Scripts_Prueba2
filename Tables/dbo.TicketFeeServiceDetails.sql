CREATE TABLE [dbo].[TicketFeeServiceDetails] (
  [TicketFeeServiceDetailsId] [int] IDENTITY,
  [TicketFeeServiceId] [int] NOT NULL,
  [TicketNumber] [varchar](30) NOT NULL,
  [AgencyId] [int] NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [CompletedBy] [int] NOT NULL,
  [CompletedOn] [datetime] NOT NULL,
  [LastUpdatedOn] [datetime] NULL,
  [LastUpdatedBy] [int] NULL,
  [ExpenseId] [int] NULL,
  [CashierCommission] [decimal](18, 2) NULL,
  CONSTRAINT [PK_TicketFeeServiceDetails_TicketFeeServiceDetails] PRIMARY KEY CLUSTERED ([TicketFeeServiceDetailsId])
)
ON [PRIMARY]
GO

CREATE INDEX [IDX_TicketFeeServiceDetails_TicketNumber]
  ON [dbo].[TicketFeeServiceDetails] ([TicketNumber])
  ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Detalles para ticket fee service', 'SCHEMA', N'dbo', 'TABLE', N'TicketFeeServiceDetails'
GO