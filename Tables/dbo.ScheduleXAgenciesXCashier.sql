CREATE TABLE [dbo].[ScheduleXAgenciesXCashier] (
  [IdScheduleXAgenciesXCashier] [int] IDENTITY,
  [Time] [time] NOT NULL,
  [DayId] [int] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [UserId] [int] NOT NULL,
  CONSTRAINT [PK_ScheduleXAgenciesXCashier] PRIMARY KEY CLUSTERED ([IdScheduleXAgenciesXCashier])
)
ON [PRIMARY]
GO

DECLARE @value SQL_VARIANT = CAST(N'' AS nvarchar(1))
EXEC sys.sp_addextendedproperty N'MS_Description', @value, 'SCHEMA', N'dbo', 'TABLE', N'ScheduleXAgenciesXCashier'
GO