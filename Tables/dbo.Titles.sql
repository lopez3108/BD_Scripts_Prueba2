CREATE TABLE [dbo].[Titles] (
  [TitleId] [int] IDENTITY,
  [ProcessTypeId] [int] NULL,
  [DeliveryTypeId] [int] NULL,
  [DeliveryBy] [varchar](50) NULL,
  [ProcessStatusId] [int] NULL,
  [Name] [varchar](70) NULL,
  [Telephone] [varchar](10) NULL,
  [Email] [varchar](50) NULL,
  [PlateNumber] [varchar](20) NULL,
  [PlateTypeId] [int] NULL,
  [USD] [decimal](18, 2) NOT NULL,
  [Fee1] [decimal](18, 2) NOT NULL,
  [Cash] [decimal](18, 2) NULL,
  [PackageNumber] [varchar](15) NULL,
  [DeliveredPackageDate] [datetime] NULL,
  [CreationDate] [datetime] NULL,
  [CreatedBy] [int] NOT NULL,
  [UpdatedBy] [int] NULL,
  [Financial] [decimal](18, 2) NULL,
  [Dunbar] [datetime] NULL,
  [AgencyId] [int] NOT NULL,
  [FeeILDOR] [decimal](18, 2) NULL,
  [MOILDOR] [decimal](18, 2) NULL,
  [FeeILSOS] [decimal](18, 2) NULL,
  [MOLSOS] [decimal](18, 2) NULL,
  [FeeOther] [decimal](18, 2) NULL,
  [MOOther] [decimal](18, 2) NULL,
  [RunnerService] [decimal](18, 2) NULL,
  [ProcessAuto] [bit] NOT NULL CONSTRAINT [DF_Titles_ProcessAuto] DEFAULT (0),
  [PlateTypePersonalizedId] [int] NULL,
  [PlateTypePersonalizedFee] [decimal](18, 2) NULL,
  [FinancingId] [int] NULL,
  [CardPayment] [bit] NOT NULL CONSTRAINT [DF_Titles_CardPayment] DEFAULT (0),
  [CardPaymentFee] [decimal](18, 2) NULL,
  [FileIdName] [varchar](max) NULL,
  [FeeEls] [decimal](18, 2) NOT NULL CONSTRAINT [DF_Titles_FeeEls] DEFAULT (0),
  [SellerId] [int] NULL,
  [BuyingPrice] [decimal](18, 2) NULL,
  [FileIdNameTitle] [varchar](max) NULL,
  [FileIdNameTitleBack] [varchar](max) NULL,
  [FileIdNameElsCopy] [varchar](max) NULL,
  [FileIdNameTitleM] [varchar](max) NULL,
  [FileIdNameTitleMBack] [varchar](max) NULL,
  [FileIdNameMo] [varchar](max) NULL,
  [FileIdNameRut] [varchar](max) NULL,
  [FileIdNameVehicle] [varchar](max) NULL,
  [FileIdNameAttorney] [varchar](max) NULL,
  [FileIdNameProofAddress] [varchar](max) NULL,
  [TelIsCheck] [bit] NULL CONSTRAINT [DF_Titles_TelIsCheck] DEFAULT (0),
  [FileIdNameMoIlsos] [varchar](max) NULL,
  [ValidatedBy] [int] NULL,
  [UpdatedOn] [datetime] NULL,
  [PlateTypeOtherTruckId] [int] NULL,
  [PlateDesignId] [int] NULL,
  [PlateTypeTrailerId] [int] NULL,
  [DatePendingState] [datetime] NULL,
  [DatePending] [datetime] NULL,
  [DateReceived] [datetime] NULL,
  [DatePendingStateBy] [int] NULL,
  [DatePendingBy] [int] NULL,
  [DateReceivedBy] [int] NULL,
  [DateCompletedBy] [int] NULL,
  [DateCompleted] [datetime] NULL,
  [FileIdName2] [varchar](max) NULL,
  [ValidatedOn] [datetime] NULL,
  [HasId2] [bit] NOT NULL DEFAULT (0),
  [HasProofAddress] [bit] NOT NULL DEFAULT (0),
  [IdExpirationDate] [datetime] NULL,
  [ChooseMsg ] [bit] NULL DEFAULT (0),
  [VinNumber] [varchar](50) NULL,
  [ExpenseId] [int] NULL,
  [CashierCommission] [decimal](18, 2) NULL,
  CONSTRAINT [PK_Titles] PRIMARY KEY CLUSTERED ([TitleId])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE UNIQUE INDEX [IX_FinancingId_NotNull]
  ON [dbo].[Titles] ([FinancingId])
  WHERE ([FinancingId] IS NOT NULL)
  ON [PRIMARY]
GO

ALTER TABLE [dbo].[Titles]
  ADD FOREIGN KEY ([ExpenseId]) REFERENCES [dbo].[Expenses] ([ExpenseId])
GO

ALTER TABLE [dbo].[Titles]
  ADD CONSTRAINT [FK_Titles_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[Titles]
  ADD CONSTRAINT [FK_Titles_DeliveryTypes] FOREIGN KEY ([DeliveryTypeId]) REFERENCES [dbo].[DeliveryTypes] ([DeliveryTypeId])
GO

ALTER TABLE [dbo].[Titles]
  ADD CONSTRAINT [FK_Titles_Financing] FOREIGN KEY ([FinancingId]) REFERENCES [dbo].[Financing] ([FinancingId])
GO

ALTER TABLE [dbo].[Titles]
  ADD CONSTRAINT [FK_Titles_PlateDesign] FOREIGN KEY ([PlateDesignId]) REFERENCES [dbo].[PlateDesign] ([PlateDesignId])
GO

ALTER TABLE [dbo].[Titles]
  ADD CONSTRAINT [FK_Titles_PlateTypeOtherTruck] FOREIGN KEY ([PlateTypeOtherTruckId]) REFERENCES [dbo].[PlateTypeOtherTruck] ([PlateTypeOtherTruckId])
GO

ALTER TABLE [dbo].[Titles] WITH NOCHECK
  ADD CONSTRAINT [FK_Titles_PlateTypes] FOREIGN KEY ([PlateTypeId]) REFERENCES [dbo].[PlateTypes] ([PlateTypeId])
GO

ALTER TABLE [dbo].[Titles]
  NOCHECK CONSTRAINT [FK_Titles_PlateTypes]
GO

ALTER TABLE [dbo].[Titles]
  ADD CONSTRAINT [FK_Titles_PlateTypesPersonalized] FOREIGN KEY ([PlateTypePersonalizedId]) REFERENCES [dbo].[PlateTypesPersonalized] ([PlateTypePersonalizedId])
GO

ALTER TABLE [dbo].[Titles]
  ADD CONSTRAINT [FK_Titles_PlateTypeTrailer] FOREIGN KEY ([PlateTypeTrailerId]) REFERENCES [dbo].[PlateTypeTrailer] ([PlateTypeTrailerId])
GO

ALTER TABLE [dbo].[Titles] WITH NOCHECK
  ADD CONSTRAINT [FK_Titles_ProccessTypes] FOREIGN KEY ([ProcessTypeId]) REFERENCES [dbo].[ProcessTypes] ([ProcessTypeId])
GO

ALTER TABLE [dbo].[Titles]
  NOCHECK CONSTRAINT [FK_Titles_ProccessTypes]
GO

ALTER TABLE [dbo].[Titles]
  ADD CONSTRAINT [FK_Titles_ProcessStatus] FOREIGN KEY ([ProcessStatusId]) REFERENCES [dbo].[ProcessStatus] ([ProcessStatusId])
GO

ALTER TABLE [dbo].[Titles]
  ADD CONSTRAINT [FK_Titles_Titles] FOREIGN KEY ([TitleId]) REFERENCES [dbo].[Titles] ([TitleId])
GO

ALTER TABLE [dbo].[Titles] WITH NOCHECK
  ADD CONSTRAINT [FK_Titles_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[Titles] WITH NOCHECK
  ADD CONSTRAINT [FK_Titles_Users1] FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO