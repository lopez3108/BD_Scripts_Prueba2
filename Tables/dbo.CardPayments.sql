CREATE TABLE [dbo].[CardPayments] (
  [CardPaymentId] [int] IDENTITY,
  [Usd] [decimal](18, 2) NULL CONSTRAINT [DF_Table_1_Notary] DEFAULT (0),
  [Fee] [decimal](18, 2) NULL CONSTRAINT [DF_Table_1_Usd1] DEFAULT (0),
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [LastUpdatedBy] [int] NULL,
  [LastUpdatedOn] [datetime] NULL,
  [FeeUsd] [decimal](18, 2) NULL,
  [TotalPay] [decimal](18, 2) NULL,
  [Batch] [bit] NULL,
  [NumberPayments] [int] NULL,
  CONSTRAINT [PK_CardPayments] PRIMARY KEY CLUSTERED ([CardPaymentId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[CardPayments]
  ADD CONSTRAINT [FK_CardPayments_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[CardPayments]
  ADD CONSTRAINT [FK_CardPayments_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO