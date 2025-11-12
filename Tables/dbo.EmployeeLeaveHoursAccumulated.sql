CREATE TABLE [dbo].[EmployeeLeaveHoursAccumulated] (
  [EmployeeLeaveHoursAccumulatedId] [int] IDENTITY,
  [UserId] [int] NOT NULL,
  [Hours] [decimal](18, 2) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [CycleDateLeaveHours] [date] NULL,
  CONSTRAINT [PK_EmployeeLeaveHoursAccumulated_EmployeeLeaveHoursAccumulatedId] PRIMARY KEY CLUSTERED ([EmployeeLeaveHoursAccumulatedId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[EmployeeLeaveHoursAccumulated]
  ADD CONSTRAINT [FK_EmployeeLeaveHoursAccumulated_CreatedBy] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[EmployeeLeaveHoursAccumulated]
  ADD CONSTRAINT [FK_EmployeeLeaveHoursAccumulated_UserId] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([UserId])
GO