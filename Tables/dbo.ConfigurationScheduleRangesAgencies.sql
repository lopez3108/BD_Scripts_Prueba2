CREATE TABLE [dbo].[ConfigurationScheduleRangesAgencies] (
  [ScheduleConfigurationId] [int] IDENTITY,
  [ToTime] [time](0) NOT NULL,
  [FromTime] [time](0) NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [UpdatedBy] [int] NOT NULL,
  [UpdatedOn] [datetime] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [CodDay] [varchar](3) NOT NULL,
  CONSTRAINT [PK_Configurationschedulerangesbydate] PRIMARY KEY CLUSTERED ([ScheduleConfigurationId])
)
ON [PRIMARY]
GO