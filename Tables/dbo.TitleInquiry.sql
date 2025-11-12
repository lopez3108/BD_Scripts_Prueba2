CREATE TABLE [dbo].[TitleInquiry] (
  [TitleInquiryId] [int] IDENTITY,
  [USD] [decimal](18, 2) NOT NULL,
  [Fee1] [decimal](18, 2) NOT NULL,
  [Cash] [decimal](18, 2) NULL,
  [CreationDate] [datetime] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [CardPayment] [bit] NOT NULL CONSTRAINT [DF_TitleInquiry_CardPayment] DEFAULT (0),
  [CardPaymentFee] [decimal](18, 2) NULL,
  [FeeEls] [decimal](18, 2) NOT NULL CONSTRAINT [DF_TitleInquiry_FeeEls] DEFAULT (0),
  [UpdatedBy] [int] NULL,
  [UpdatedOn] [datetime] NULL,
  CONSTRAINT [PK_TitleInquiry] PRIMARY KEY CLUSTERED ([TitleInquiryId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[TitleInquiry]
  ADD CONSTRAINT [FK_TitleInquiry_Agency] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO