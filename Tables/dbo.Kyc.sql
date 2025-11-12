CREATE TABLE [dbo].[Kyc] (
  [KycId] [int] IDENTITY,
  [AgencyId] [int] NULL,
  [OrderNumber] [varchar](15) NULL,
  [ClientName] [varchar](40) NULL,
  [CreationDate] [datetime] NULL,
  [UserId] [int] NULL,
  [Name] [varchar](150) NULL,
  [Extension] [varchar](25) NULL,
  [Base64] [varchar](max) NULL,
  [ProviderId] [int] NULL,
  [Usd] [decimal](18, 2) NULL,
  [LastUpdatedBy] [int] NULL,
  [LastUpdatedOn] [datetime] NULL,
  PRIMARY KEY CLUSTERED ([KycId])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Kyc]
  ADD FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[Kyc]
  ADD CONSTRAINT [FK__Kyc__ProviderId__2196D523] FOREIGN KEY ([ProviderId]) REFERENCES [dbo].[Providers] ([ProviderId])
GO

ALTER TABLE [dbo].[Kyc]
  ADD CONSTRAINT [FK__Kyc__UserId__6D630406] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([UserId])
GO