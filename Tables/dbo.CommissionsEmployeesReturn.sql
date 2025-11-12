CREATE TABLE [dbo].[CommissionsEmployeesReturn] (
  [CommissionEmployeeReturnId] [int] IDENTITY,
  [ExpenseId] [int] NULL,
  [CreatedBy] [int] NULL,
  [AgencyId] [int] NULL,
  [CashierCommission] [decimal](18, 2) NULL,
  [CreationDate] [datetime] NULL,
  [Provider] [varchar](50) NULL,
  [UserLoginId] [varchar](50) NULL,
  [ExpensePaidId] [int] NULL,
  [DateLogin] [datetime] NULL,
  CONSTRAINT [PK_CommissionsEmployeesReturn_commissionsEmployeesReturnId] PRIMARY KEY CLUSTERED ([CommissionEmployeeReturnId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[CommissionsEmployeesReturn]
  ADD CONSTRAINT [FK_CommissionsEmployeesReturn_ExpensePaidId] FOREIGN KEY ([ExpensePaidId]) REFERENCES [dbo].[Expenses] ([ExpenseId])
GO