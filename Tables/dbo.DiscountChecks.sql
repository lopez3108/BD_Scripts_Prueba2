CREATE TABLE [dbo].[DiscountChecks] (
  [DiscountCheckId] [int] IDENTITY,
  [CheckNumber] [varchar](50) NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  [Discount] [decimal](18, 2) NOT NULL,
  [ActualClient] [varchar](50) NOT NULL,
  [ReferedClient] [varchar](50) NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [IsActualClient] [bit] NOT NULL CONSTRAINT [DF_DiscountChecks_IsActualClient] DEFAULT (0),
  [LastUpdatedOn] [datetime] NULL,
  [LastUpdatedBy] [int] NULL,
  [TelIsCheck] [bit] NULL CONSTRAINT [DF_DiscountChecks_TelIsCheck] DEFAULT (0),
  [ActualClientTelephone] [varchar](10) NOT NULL,
  [Account] [varchar](50) NULL,
  CONSTRAINT [PK_DiscountChecks] PRIMARY KEY CLUSTERED ([DiscountCheckId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[DiscountChecks]
  ADD CONSTRAINT [FK_DiscountChecks_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[DiscountChecks]
  ADD CONSTRAINT [FK_DiscountChecks_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO