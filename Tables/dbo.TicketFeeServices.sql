CREATE TABLE [dbo].[TicketFeeServices] (
  [TicketFeeServiceId] [int] IDENTITY,
  [Usd] [decimal](18, 2) NOT NULL,
  [UsedCard] [bit] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [CardPaymentFee] [decimal](18, 2) NULL CONSTRAINT [DF_TicketFeeServices_CardPaymentFee] DEFAULT (0),
  [UpdatedBy] [int] NULL,
  [UpdatedOn] [datetime] NULL,
  [Plus] [int] NULL,
  [Cash] [decimal](18, 2) NULL,
  [CashierCommission] [decimal](18, 2) NULL,
  CONSTRAINT [PK_TicketFeeServices] PRIMARY KEY CLUSTERED ([TicketFeeServiceId])
)
ON [PRIMARY]
GO