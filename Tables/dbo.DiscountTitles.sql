CREATE TABLE [dbo].[DiscountTitles] (
  [DiscountTitleId] [int] IDENTITY,
  [TitleId] [int] NOT NULL,
  [Discount] [decimal](18, 2) NOT NULL,
  [ReasonId] [int] NOT NULL,
  [OtherReason] [varchar](50) NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [LastUpdatedOn] [datetime] NULL,
  [LastUpdatedBy] [int] NULL,
  [TelIsCheck] [bit] NULL CONSTRAINT [DF_DiscountTitles_TelIsCheck] DEFAULT (0),
  [ActualClientTelephone] [varchar](10) NOT NULL,
  [Usd] [decimal](18, 2) NULL,
  CONSTRAINT [PK_DiscountTitles] PRIMARY KEY CLUSTERED ([DiscountTitleId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[DiscountTitles]
  ADD CONSTRAINT [FK_DiscountTitles_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[DiscountTitles]
  ADD CONSTRAINT [FK_DiscountTitles_Reasons] FOREIGN KEY ([ReasonId]) REFERENCES [dbo].[Reasons] ([ReasonId])
GO

ALTER TABLE [dbo].[DiscountTitles]
  ADD CONSTRAINT [FK_DiscountTitles_Titles] FOREIGN KEY ([TitleId]) REFERENCES [dbo].[Titles] ([TitleId])
GO

ALTER TABLE [dbo].[DiscountTitles]
  ADD CONSTRAINT [FK_DiscountTitles_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO