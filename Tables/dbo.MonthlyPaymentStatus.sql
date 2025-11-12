CREATE TABLE [dbo].[MonthlyPaymentStatus] (
  [MonthlyPaymentStatusId] [int] IDENTITY,
  [Code] [varchar](4) NOT NULL,
  [Description] [varchar](20) NOT NULL,
  PRIMARY KEY CLUSTERED ([MonthlyPaymentStatusId])
)
ON [PRIMARY]
GO