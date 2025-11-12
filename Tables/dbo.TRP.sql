CREATE TABLE [dbo].[TRP] (
  [TRPId] [int] IDENTITY,
  [PermitTypeId] [int] NULL,
  [PermitNumber] [varchar](20) NULL,
  [ClientName] [varchar](70) NULL,
  [Telephone] [varchar](10) NOT NULL,
  [Email] [varchar](50) NULL,
  [USD] [decimal](18, 2) NOT NULL,
  [Fee1] [decimal](18, 2) NOT NULL,
  [Cash] [decimal](18, 2) NULL,
  [CreatedOn] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [CardPayment] [bit] NOT NULL CONSTRAINT [DF_TRP_CardPayment] DEFAULT (0),
  [CardPaymentFee] [decimal](18, 2) NULL,
  [FileIdName] [varchar](1000) NULL,
  [TrpFee] [decimal](18, 2) NULL,
  [UpdatedBy] [int] NULL,
  [UpdatedOn] [datetime] NULL,
  [LaminationFee] [decimal](18, 2) NULL,
  [FileIdNamePermit] [varchar](1000) NULL,
  [FileIdNameTrpT] [varchar](1000) NULL,
  [FileIdNameTrpTBack] [varchar](1000) NULL,
  [FileIdNameProofAddress] [varchar](max) NULL,
  [TelIsCheck] [bit] NULL,
  [FileIdName2] [varchar](1000) NULL,
  [VinPertmitTrpId] [int] NULL,
  [VinNumber] [varchar](17) NULL,
  [HasId2] [bit] NOT NULL DEFAULT (0),
  [HasProofAddress] [bit] NOT NULL DEFAULT (0),
  [Paid] [bit] NULL DEFAULT (0),
  [PaidBy] [int] NULL,
  [PaymentDate] [datetime] NULL,
  [IdExpirationDate] [datetime] NULL,
  [FeeElsSale] [decimal](18, 2) NULL,
  [FeeElsTrpSale] [decimal](18, 2) NULL,
  [ExpenseId] [int] NULL,
  [CashierCommission] [decimal](18, 2) NULL,
  CONSTRAINT [PK_TRP] PRIMARY KEY CLUSTERED ([TRPId])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE UNIQUE INDEX [IX_Permit_Number]
  ON [dbo].[TRP] ([PermitNumber])
  WHERE ([PermitNumber] IS NOT NULL)
  ON [PRIMARY]
GO

ALTER TABLE [dbo].[TRP]
  ADD FOREIGN KEY ([ExpenseId]) REFERENCES [dbo].[Expenses] ([ExpenseId])
GO

ALTER TABLE [dbo].[TRP]
  ADD CONSTRAINT [FK_TRP_Agency] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[TRP]
  ADD CONSTRAINT [FK_TRP_PERMITTYPE] FOREIGN KEY ([PermitTypeId]) REFERENCES [dbo].[PermitTypes] ([PermitTypeId])
GO

ALTER TABLE [dbo].[TRP]
  ADD CONSTRAINT [FK_TRP_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO