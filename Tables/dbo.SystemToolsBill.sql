CREATE TABLE [dbo].[SystemToolsBill] (
  [BillId] [int] IDENTITY,
  [CreationDate] [datetime] NULL,
  [CreatedBy] [int] NULL,
  [Total] [decimal](18, 2) NOT NULL,
  [Cash] [decimal](18, 2) NULL,
  [Change] [decimal](18, 2) NULL,
  [CardPayment] [bit] NULL,
  [CardPaymentFee] [decimal](18, 2) NOT NULL CONSTRAINT [DF_SystemToolsBill_CardPaymentFee] DEFAULT (0),
  [AgencyId] [int] NULL,
  [LastUpdatedOn] [datetime] NULL,
  [LastUpdatedBy] [int] NULL,
  CONSTRAINT [PK_SystemToolsBill] PRIMARY KEY CLUSTERED ([BillId])
)
ON [PRIMARY]
GO