CREATE TABLE [dbo].[PaymentAdjustment] (
  [PaymentAdjustmentId] [int] IDENTITY,
  [AgencyFromId] [int] NOT NULL,
  [AgencyToId] [int] NOT NULL,
  [ProviderId] [int] NOT NULL,
  [USD] [decimal](18, 2) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [DeletedOn] [datetime] NULL,
  [DeletedBy] [int] NULL,
  [Date] [datetime] NOT NULL,
  CONSTRAINT [PK__PaymentA__E14CE1014987AC94] PRIMARY KEY CLUSTERED ([PaymentAdjustmentId])
)
ON [PRIMARY]
GO