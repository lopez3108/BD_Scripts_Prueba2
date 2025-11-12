CREATE TABLE [dbo].[ContractExpenses] (
  [ContractExpenseId] [int] IDENTITY,
  [ApartmentId] [int] NOT NULL,
  [ContractId] [int] NULL,
  [ContactExpenseTypeId] [int] NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  [DownPaymentUsd] [decimal](18, 2) NULL,
  [Description] [varchar](50) NULL,
  [Note] [varchar](300) NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [AgencyId] [int] NULL,
  [MoneyOrder] [varchar](12) NULL,
  [CheckNumber] [varchar](15) NULL,
  [BankId] [int] NULL,
  [Account] [varchar](15) NULL,
  [CardNumber] [varchar](20) NULL
)
ON [PRIMARY]
GO