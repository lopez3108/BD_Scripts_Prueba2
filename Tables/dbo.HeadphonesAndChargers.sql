CREATE TABLE [dbo].[HeadphonesAndChargers] (
  [HeadphonesAndChargerId] [int] IDENTITY,
  [HeadphonesQuantity] [int] NULL,
  [HeadphonesUsd] [decimal](18, 2) NULL,
  [ChargersQuantity] [int] NULL,
  [ChargersUsd] [decimal](18, 2) NULL,
  [CreatedBy] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [CostHeadPhones] [decimal](18, 2) NULL CONSTRAINT [DF__Headphone__CostH__73D00A73] DEFAULT (0),
  [CostChargers] [decimal](18, 2) NULL CONSTRAINT [DF__Headphone__CostC__74C42EAC] DEFAULT (0),
  [UpdatedBy] [int] NULL,
  [UpdatedOn] [datetime] NULL,
  [CardPayment] [bit] NOT NULL,
  [CardPaymentFee] [decimal](18, 2) NULL,
  CONSTRAINT [PK_HeadphonesAndCharges] PRIMARY KEY CLUSTERED ([HeadphonesAndChargerId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[HeadphonesAndChargers]
  ADD CONSTRAINT [FK_HeadphonesAndChargers_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[HeadphonesAndChargers]
  ADD CONSTRAINT [FK_HeadphonesAndChargers_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO