CREATE TABLE [dbo].[UserPass] (
  [UserPassId] [int] IDENTITY,
  [Company] [varchar](100) NOT NULL,
  [Pass] [varchar](20) NOT NULL,
  [UserId] [int] NOT NULL,
  [User] [varchar](50) NOT NULL,
  [AgencyId] [int] NULL,
  [Url] [varchar](400) NULL,
  [UpdatedOn] [datetime] NULL,
  [UpdatedBy] [int] NULL,
  [InitialFromDate] [date] NULL,
  [InitialToDate] [date] NULL,
  [InitialIndefined] [bit] NULL,
  [AgencyNumber] [varchar](10) NULL,
  [TokenNumber] [varchar](30) NULL,
  CONSTRAINT [PK_UserPass] PRIMARY KEY CLUSTERED ([UserPassId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[UserPass] WITH NOCHECK
  ADD CONSTRAINT [FK_UserPass_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId]) NOT FOR REPLICATION
GO

ALTER TABLE [dbo].[UserPass]
  NOCHECK CONSTRAINT [FK_UserPass_Agencies]
GO

ALTER TABLE [dbo].[UserPass]
  ADD CONSTRAINT [FK_UserPass_Users] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([UserId])
GO