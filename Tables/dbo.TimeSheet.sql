CREATE TABLE [dbo].[TimeSheet] (
  [TimeSheetId] [int] IDENTITY,
  [UserId] [int] NOT NULL,
  [LoginDate] [datetime] NOT NULL,
  [LogoutDate] [datetime] NULL,
  [LastUpdatedOn] [datetime] NULL,
  [LastUpdatedBy] [int] NULL,
  [AgencyId] [int] NULL,
  [EstimatedDepartureTime] [time] NULL,
  [StatusId] [int] NULL,
  [ApprovedOn] [datetime] NULL,
  [ApprovedBy] [int] NULL,
  [Rol] [int] NULL,
  [PreApproved] [bit] NULL,
  CONSTRAINT [PK_TimeSheet] PRIMARY KEY CLUSTERED ([TimeSheetId])
)
ON [PRIMARY]
GO