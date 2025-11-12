CREATE TABLE [dbo].[EmployeeVacations] (
  [EmployeeVacationsId] [int] IDENTITY,
  [UserId] [int] NOT NULL,
  [Hours] [decimal](18, 2) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [CycleDateVacation] [date] NULL,
  [PayrollId] [int] NULL,
  [FileName] [varchar](1000) NULL,
  CONSTRAINT [PK_EmployeeVacations_EmployeeVacationsId] PRIMARY KEY CLUSTERED ([EmployeeVacationsId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[EmployeeVacations]
  ADD CONSTRAINT [FK_EmployeeVacations_PayrollId] FOREIGN KEY ([PayrollId]) REFERENCES [dbo].[Payrolls] ([PayrollId])
GO