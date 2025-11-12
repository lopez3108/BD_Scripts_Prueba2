CREATE TABLE [dbo].[EmployeeHandBook] (
  [EmployeeHandbookId] [int] IDENTITY,
  [EmployeeHandbook] [varchar](1000) NULL,
  CONSTRAINT [PK_EmployeeHandBook_EmployeeHandbookId] PRIMARY KEY CLUSTERED ([EmployeeHandbookId])
)
ON [PRIMARY]
GO