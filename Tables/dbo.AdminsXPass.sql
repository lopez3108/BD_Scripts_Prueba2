CREATE TABLE [dbo].[AdminsXPass] (
  [UserXPassId] [int] IDENTITY,
  [UserPassId] [int] NOT NULL,
  [UserId] [int] NOT NULL,
  [FromDate] [date] NULL,
  [ToDate] [date] NULL,
  [Indefined] [bit] NULL,
  CONSTRAINT [PK_AdminsXPass] PRIMARY KEY CLUSTERED ([UserXPassId])
)
ON [PRIMARY]
GO