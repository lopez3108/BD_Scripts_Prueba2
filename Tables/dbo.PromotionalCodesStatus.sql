CREATE TABLE [dbo].[PromotionalCodesStatus] (
  [PromotionalCodeStatusId] [int] IDENTITY,
  [PromotionalCodeId] [int] NOT NULL,
  [Code] [char](4) NOT NULL,
  [Used] [bit] NOT NULL CONSTRAINT [DF_Table_1_UsedId] DEFAULT (0),
  [Usd] [decimal](18, 2) NULL,
  [UsedDate] [datetime] NULL,
  [AgencyUsedId] [int] NULL,
  [UserUsedId] [int] NULL,
  [CheckId] [int] NULL,
  [CityStickerId] [int] NULL,
  [PlateStickerId] [int] NULL,
  [TitleId] [int] NULL,
  [ActualClientTelephone] [varchar](10) NULL,
  [TelIsCheck] [bit] NULL CONSTRAINT [DF_PromotionalCodesStatus_TelIsCheck] DEFAULT (0),
  [Reusable] [bit] NULL,
  [SentSMSDate] [datetime] NULL,
  CONSTRAINT [PK_PromotionalCodesStatus] PRIMARY KEY CLUSTERED ([PromotionalCodeStatusId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[PromotionalCodesStatus]
  ADD CONSTRAINT [FK_PromotionalCodesStatus_Agencies] FOREIGN KEY ([AgencyUsedId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[PromotionalCodesStatus]
  ADD CONSTRAINT [FK_PromotionalCodesStatus_PromotionalCodes] FOREIGN KEY ([PromotionalCodeId]) REFERENCES [dbo].[PromotionalCodes] ([PromotionalCodeId])
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'This field works to know the date when the promotional code was sent to the client telephone', 'SCHEMA', N'dbo', 'TABLE', N'PromotionalCodesStatus'
GO