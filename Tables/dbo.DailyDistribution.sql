CREATE TABLE [dbo].[DailyDistribution] (
  [DailyDistributionId] [int] IDENTITY,
  [DailyId] [int] NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  [PackageNumber] [varchar](15) NULL,
  [ProviderId] [int] NULL,
  [AgencyId] [int] NULL,
  [Code] [varchar](20) NULL,
  [BankAccountId] [int] NULL,
  [ImageName] [varchar](100) NULL,
  [ImageNameBook] [varchar](100) NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [UpdatedOn] [datetime] NULL,
  [UpdatedBy] [varchar](50) NULL,
  CONSTRAINT [PK_DailyDistribution] PRIMARY KEY CLUSTERED ([DailyDistributionId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[DailyDistribution]
  ADD CONSTRAINT [FK_DailyDistribution_BankAccountId] FOREIGN KEY ([BankAccountId]) REFERENCES [dbo].[BankAccounts] ([BankAccountId])
GO

ALTER TABLE [dbo].[DailyDistribution]
  ADD CONSTRAINT [FK_DailyDistribution_Daily] FOREIGN KEY ([DailyId]) REFERENCES [dbo].[Daily] ([DailyId])
GO