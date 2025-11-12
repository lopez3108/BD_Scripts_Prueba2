CREATE TABLE [dbo].[EmployeeLeaveHours] (
  [EmployeeLeaveHoursId] [int] IDENTITY,
  [UserId] [int] NOT NULL,
  [Hours] [decimal](18, 2) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [CycleDateLeaveHours] [date] NULL,
  [PayrollId] [int] NULL,
  [FileName] [varchar](1000) NULL,
  CONSTRAINT [PK_EmployeeLeaveHours_EmployeeLeaveHoursId] PRIMARY KEY NONCLUSTERED ([EmployeeLeaveHoursId])
)
ON [PRIMARY]
GO

CREATE UNIQUE CLUSTERED INDEX [UK_EmployeeLeaveHours_EmployeeLeaveHoursId]
  ON [dbo].[EmployeeLeaveHours] ([EmployeeLeaveHoursId])
  ON [PRIMARY]
GO

ALTER TABLE [dbo].[EmployeeLeaveHours]
  ADD CONSTRAINT [FK_EmployeeLeaveHours_CreatedBy] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[EmployeeLeaveHours]
  ADD CONSTRAINT [FK_EmployeeLeaveHours_PayrollId] FOREIGN KEY ([PayrollId]) REFERENCES [dbo].[Payrolls] ([PayrollId])
GO

ALTER TABLE [dbo].[EmployeeLeaveHours]
  ADD CONSTRAINT [FK_EmployeeLeaveHours_UserId] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([UserId])
GO