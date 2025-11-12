CREATE TABLE [dbo].[BreakTimeHistory] (
  [TimeBreakHistoryId] [int] IDENTITY,
  [UserId] [int] NULL,
  [DateFrom] [datetime] NULL,
  [DateTo] [datetime] NULL,
  [AgencyId] [int] NULL,
  [Rol] [int] NULL,
  CONSTRAINT [PK_BreakTimeHistory] PRIMARY KEY CLUSTERED ([TimeBreakHistoryId])
)
ON [PRIMARY]
GO