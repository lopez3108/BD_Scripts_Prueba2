CREATE TABLE [dbo].[Agencies] (
  [AgencyId] [int] IDENTITY,
  [AdminId] [int] NOT NULL,
  [Name] [varchar](50) NOT NULL,
  [Code] [varchar](10) NOT NULL,
  [Manager] [varchar](50) NULL,
  [Telephone] [varchar](20) NOT NULL,
  [Telephone2] [varchar](20) NULL,
  [Fax] [varchar](20) NULL,
  [Email] [varchar](100) NULL,
  [ZipCode] [varchar](10) NOT NULL,
  [Address] [varchar](100) NOT NULL,
  [Owner] [varchar](50) NULL,
  [IsActive] [bit] NOT NULL CONSTRAINT [DF_Agencies_IsActive] DEFAULT (1),
  [InitialBalanceCash] [decimal](18, 2) NOT NULL CONSTRAINT [DF_Agencies_InitialBalance] DEFAULT (0),
  [Mid] [varchar](20) NULL,
  [FlexxizCode] [varchar](4) NULL,
  [LastInitialBalanceSaved] [datetime] NULL,
  [LastInitialBalanceBy] [int] NULL,
  [AgencyCreatedOn] [datetime] NULL,
  [AgencyCreatedBy] [int] NULL,
  [AgencyLastUpdatedBy] [int] NULL,
  [AgencyLastUpdatedOn] [datetime] NULL,
  CONSTRAINT [PK_Agencies] PRIMARY KEY CLUSTERED ([AgencyId])
)
ON [PRIMARY]
GO

CREATE UNIQUE INDEX [IX_Agencies_Code]
  ON [dbo].[Agencies] ([Code])
  ON [PRIMARY]
GO