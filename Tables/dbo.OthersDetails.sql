CREATE TABLE [dbo].[OthersDetails] (
  [OtherDetailId] [int] IDENTITY,
  [OtherServiceId] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  [Concept] [varchar](70) NULL,
  [CreatedBy] [int] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [CardPayment] [bit] NOT NULL,
  [CardPaymentFee] [decimal](18, 2) NULL,
  [UpdatedBy] [int] NULL,
  [UpdatedOn] [datetime] NULL,
  [ValidatedBy] [int] NULL,
  [ValidatedOn] [datetime] NULL,
  [Cash] [decimal](18, 2) NULL,
  CONSTRAINT [PK_OthersDetails] PRIMARY KEY CLUSTERED ([OtherDetailId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[OthersDetails]
  ADD CONSTRAINT [FK_OthersDetails_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[OthersDetails]
  ADD CONSTRAINT [FK_OthersDetails_OthersServices] FOREIGN KEY ([OtherServiceId]) REFERENCES [dbo].[OthersServices] ([OtherId])
GO

ALTER TABLE [dbo].[OthersDetails]
  ADD CONSTRAINT [FK_OthersDetails_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO