CREATE TABLE [dbo].[EmployeeWarning] (
  [EmployeeWarningId] [int] IDENTITY,
  [UserId] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [Name] [varchar](150) NOT NULL,
  [CreatedBy] [int] NOT NULL,
  CONSTRAINT [PK_EmployeeWarning_EmployeeWarningId] PRIMARY KEY CLUSTERED ([EmployeeWarningId])
)
ON [PRIMARY]
GO