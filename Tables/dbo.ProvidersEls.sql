CREATE TABLE [dbo].[ProvidersEls] (
  [ProviderElsId] [int] IDENTITY,
  [Code] [varchar](6) NULL,
  [Name] [varchar](50) NOT NULL,
  [AllowFee1Default] [bit] NOT NULL CONSTRAINT [DF_ProvidersEls_Allow1Default] DEFAULT (0),
  [Fee1Default] [decimal](18, 2) NOT NULL,
  [AllowFee2] [bit] NOT NULL CONSTRAINT [DF_ProvidersEls_AllowFee2] DEFAULT (0),
  [AllowDefaultUsd] [bit] NOT NULL CONSTRAINT [DF_ProvidersEls_AllowDefaultUsd] DEFAULT (0),
  [DefaultUsd] [decimal](18, 2) NULL,
  [FeeELS] [decimal](18, 2) NULL,
  [FeeCollect] [decimal](18, 2) NULL CONSTRAINT [DF_ProvidersEls_FeeCollect] DEFAULT (0),
  [FeeELSTrp] [decimal](18, 2) NULL,
  [FeeElsSale] [decimal](18, 2) NULL,
  [FeeElsTrpSale] [decimal](18, 2) NULL,
  CONSTRAINT [PK_ProvidersEls] PRIMARY KEY CLUSTERED ([ProviderElsId])
)
ON [PRIMARY]
GO