CREATE TABLE [dbo].[EmployeeVacationsAccumulated] (
  [EmployeeVacationsAccumulatedId] [int] IDENTITY,
  [UserId] [int] NOT NULL,
  [Hours] [decimal](18, 2) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [CycleDateVacation] [date] NULL,
  CONSTRAINT [PK_EmployeeVacationsAccumulated_EmployeeVacationsAccumulatedId] PRIMARY KEY CLUSTERED ([EmployeeVacationsAccumulatedId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[EmployeeVacationsAccumulated]
  ADD CONSTRAINT [FK_EmployeeVacationsAccumulated_CreatedBy] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[EmployeeVacationsAccumulated]
  ADD CONSTRAINT [FK_EmployeeVacationsAccumulated_UserId] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([UserId])
GO