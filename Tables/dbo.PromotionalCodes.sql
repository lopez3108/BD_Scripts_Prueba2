CREATE TABLE [dbo].[PromotionalCodes] (
  [PromotionalCodeId] [int] IDENTITY,
  [Description] [varchar](40) NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  [FromDate] [datetime] NOT NULL,
  [ToDate] [datetime] NOT NULL,
  [Message] [varchar](250) NOT NULL,
  [Reusable] [bit] NOT NULL CONSTRAINT [DF_PromotionalCodes_Reusable] DEFAULT (0),
  [Code] [char](4) NULL,
  [CreatedBy] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [SentSMSDate] [datetime] NULL,
  [TypePromotional] [char](5) NULL,
  [Percentage] [bit] NULL,
  [RedeemFromDate] [date] NULL,
  [RedeemToDate] [date] NULL,
  [LastUpdatedOn] [datetime] NULL,
  [LastUpdatedBy] [int] NULL,
  CONSTRAINT [PK_PromotionalCodes] PRIMARY KEY CLUSTERED ([PromotionalCodeId])
)
ON [PRIMARY]
GO