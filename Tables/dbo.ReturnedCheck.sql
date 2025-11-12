CREATE TABLE [dbo].[ReturnedCheck] (
  [ReturnedCheckId] [int] IDENTITY,
  [ReturnDate] [datetime] NOT NULL,
  [ProviderId] [int] NULL,
  [BelongAgencyId] [int] NOT NULL,
  [ReturnedAgencyId] [int] NOT NULL,
  [CheckDate] [datetime] NOT NULL,
  [MakerId] [int] NOT NULL,
  [CheckNumber] [varchar](15) NOT NULL,
  [USD] [decimal](18, 2) NOT NULL,
  [Fee] [decimal](18, 2) NOT NULL,
  [ProviderFee] [decimal](18, 2) NULL,
  [ReturnReasonId] [int] NOT NULL,
  [StatusId] [int] NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [LastModifiedDate] [datetime] NULL,
  [LastModifiedBy] [int] NULL,
  [ClientId] [int] NOT NULL,
  [AddressXMakerId] [int] NOT NULL,
  [AddressXClientId] [int] NOT NULL,
  [CardPayment] [bit] NOT NULL CONSTRAINT [DF_ReturnedCheck_CardPayment] DEFAULT (0),
  [CardPaymentFee] [decimal](18, 2) NULL,
  [LostBy] [int] NULL,
  [LostDate] [datetime] NULL,
  [Account] [varchar](50) NOT NULL,
  [Routing] [varchar](50) NOT NULL,
  [ClientBlocked] [bit] NULL CONSTRAINT [DF_ReturnedCheck_ClientBlocked] DEFAULT (0),
  [MakerBlocked] [bit] NULL CONSTRAINT [DF_ReturnedCheck_MakerBlockerd] DEFAULT (0),
  [AccountBlocked] [bit] NULL CONSTRAINT [DF_ReturnedCheck_AccountBlocked] DEFAULT (0),
  [AdminAgencyId] [int] NULL,
  [LawyerFee] [bit] NULL DEFAULT (0),
  [CourtFee] [bit] NULL DEFAULT (0),
  CONSTRAINT [PK_ReturnedCheck] PRIMARY KEY CLUSTERED ([ReturnedCheckId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[ReturnedCheck]
  ADD CONSTRAINT [FK_ReturnedCheck_Agencies] FOREIGN KEY ([ReturnedAgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[ReturnedCheck]
  ADD CONSTRAINT [FK_ReturnedCheck_Clientes] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Clientes] ([ClienteId])
GO

ALTER TABLE [dbo].[ReturnedCheck]
  ADD CONSTRAINT [FK_ReturnedCheck_Makers] FOREIGN KEY ([MakerId]) REFERENCES [dbo].[Makers] ([MakerId])
GO