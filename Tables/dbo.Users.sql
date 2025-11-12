CREATE TABLE [dbo].[Users] (
  [UserId] [int] IDENTITY,
  [Name] [varchar](80) NOT NULL,
  [Telephone] [varchar](20) NULL,
  [Telephone2] [varchar](20) NULL,
  [ZipCode] [varchar](10) NULL,
  [Address] [varchar](70) NULL,
  [User] [varchar](50) NULL,
  [Pass] [varchar](50) NULL,
  [UserType] [int] NOT NULL,
  [Lenguage] [int] NOT NULL CONSTRAINT [DF_Users_Lenguage] DEFAULT (1),
  [StartingDate] [datetime] NULL,
  [FingerPrintTemplate] [varchar](max) NULL,
  [SocialSecurity] [varchar](20) NULL,
  [PaymentType] [varchar](10) NULL,
  [USD] [decimal](18, 2) NULL,
  [BirthDay] [datetime] NULL,
  [TelIsCheck] [bit] NULL CONSTRAINT [DF_Users_TelIsCheck] DEFAULT (0),
  [EmailIsCheck] [bit] NULL CONSTRAINT [DF_Users_EmailIsCheck] DEFAULT (0),
  [LastPasswordChangeDate] [datetime] NULL,
  [HoursPromedial] [decimal](18, 2) NULL,
  [VacationHoursAccumulated] [decimal](18, 2) NULL,
  [LastLoginDateAdmin] [datetime] NULL,
  [LastLoginDateManager] [datetime] NULL,
  [UserCreatedOn] [datetime] NULL,
  [UserCreatedBy] [int] NULL,
  [UserLastUpdatedOn] [datetime] NULL,
  [UserLastUpdatedBy] [int] NULL,
  [LastUpdatedStartingDate ] [datetime] NULL,
  [LastUpdatedStartingDateBy] [int] NULL,
  [LastUpdatedsalaryOn] [datetime] NULL,
  [LastUpdatedSalaryBy] [int] NULL,
  [LastUpdatedSickHrsOn] [datetime] NULL,
  [LastUpdatedSickHrsBy] [int] NULL,
  CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED ([UserId])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE UNIQUE INDEX [IX_Users_SocialSecurity_UniqueByPaymentType]
  ON [dbo].[Users] ([SocialSecurity])
  WHERE ([PaymentType] IS NOT NULL)
  ON [PRIMARY]
GO

DECLARE @value SQL_VARIANT = CAST(N'' AS nvarchar(1))
EXEC sys.sp_addextendedproperty N'MS_Description', @value, 'SCHEMA', N'dbo', 'TABLE', N'Users'
GO

CREATE FULLTEXT INDEX
  ON [dbo].[Users]([Name] LANGUAGE 1033)
  KEY INDEX [PK_Users]
  ON [FullTextCatalog]
  WITH CHANGE_TRACKING AUTO, STOPLIST SYSTEM
GO