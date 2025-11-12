CREATE TABLE [dbo].[Providers] (
  [ProviderId] [int] IDENTITY,
  [Name] [varchar](50) NOT NULL,
  [ProviderTypeId] [int] NOT NULL,
  [AcceptNegative] [bit] NOT NULL CONSTRAINT [DF_Providers_AcceptNegative] DEFAULT (0),
  [Comision] [decimal](18, 2) NULL,
  [Active] [bit] NULL CONSTRAINT [DF_Providers_Active] DEFAULT (1),
  [ShowInBalance] [bit] NOT NULL CONSTRAINT [DF_Providers_ShowInBalance] DEFAULT (0),
  [CheckCommission] [decimal](18, 2) NULL CONSTRAINT [DF_Providers_CheckCommission] DEFAULT (0.00),
  [MoneyOrderCommission] [decimal](18, 2) NULL CONSTRAINT [DF_Providers_CheckCommission1] DEFAULT (0.00),
  [ReturnedCheckCommission] [decimal](18, 2) NULL,
  [CostAndCommission] [bit] NOT NULL CONSTRAINT [DF_CostAndCommission ] DEFAULT (0),
  [DetailedTransaction] [bit] NOT NULL DEFAULT (0),
  [LimitBalance] [bit] NULL CONSTRAINT [DF_Providers_LimitBalance] DEFAULT (0),
  [MoneyOrderService] [bit] NOT NULL CONSTRAINT [DF_Providers_MoneyOrderService] DEFAULT (0),
  [UseSmartSafeDeposit] [bit] NOT NULL CONSTRAINT [DF_Providers_UseSmartSafeDeposit] DEFAULT (0),
  [SmartSafeDepositVoucherRequired] [bit] NOT NULL CONSTRAINT [DF_Providers_SmartSafeDepositVoucherRequired] DEFAULT (0),
  [UseCashAdvanceOrBack] [bit] NULL DEFAULT (0),
  [CashAdvanceOrBackVoucherRequired] [bit] NULL DEFAULT (0),
  [ForexType] [int] NULL,
  CONSTRAINT [PK_Providers] PRIMARY KEY CLUSTERED ([ProviderId])
)
ON [PRIMARY]
GO

CREATE UNIQUE INDEX [IX_Providers]
  ON [dbo].[Providers] ([Name])
  ON [PRIMARY]
GO