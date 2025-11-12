CREATE TABLE [dbo].[Contract] (
  [ContractId] [int] IDENTITY,
  [ApartmentId] [int] NULL,
  [StartDate] [datetime] NOT NULL,
  [EndDate] [datetime] NOT NULL,
  [RentValue] [decimal](18, 2) NOT NULL,
  [DownPayment] [decimal](18, 2) NOT NULL,
  [LengthId] [int] NOT NULL,
  [Status] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [LastUpdatedOn] [datetime] NULL,
  [LastUpdatedBy] [int] NULL,
  [FinancingDeposit] [bit] NULL CONSTRAINT [DF__Contract__Financ__3B4BBA2E] DEFAULT (0),
  [ClosedDate] [datetime] NULL,
  [SetAvailableDeposit] [bit] NULL CONSTRAINT [DF__Contract__SetAva__7C7A5F0D] DEFAULT (0),
  [RefundDate] [datetime] NULL,
  [RefundBy] [int] NULL,
  [AgencyRefundId] [int] NULL,
  [AgencyId] [int] NOT NULL,
  [RefundUsd] [decimal](18, 2) NULL,
  [Adults] [int] NOT NULL CONSTRAINT [DF_Contract_Adults] DEFAULT (0),
  [Children] [int] NULL CONSTRAINT [DF_Contract_Children] DEFAULT (0),
  [Pets] [bit] NOT NULL CONSTRAINT [DF_Contract_Pets] DEFAULT (0),
  [PetsReason] [varchar](200) NULL,
  [ClosedBy] [int] NULL,
  [ContractFileName] [varchar](200) NULL,
  [Dayslate] [int] NULL,
  [MonthlyPaymentDate] [int] NULL,
  [FeeDue] [decimal](18, 2) NULL,
  [AddTerms] [bit] NULL CONSTRAINT [DF_Contract_AddTerms] DEFAULT (0),
  [FeeNfs] [decimal](18, 2) NULL,
  [DaysMaxiAband] [int] NULL,
  [DepositBankAccountId] [int] NULL,
  [MoveInFee] [decimal](18, 2) NULL,
  [TextConsent] [bit] NULL CONSTRAINT [DF__Contract__TextCo__3771D300] DEFAULT (0),
  [DepositRefundFee] [decimal](18, 2) NOT NULL CONSTRAINT [DF__Contract__Deposi__1429621A] DEFAULT (0),
  [DepositRefundPaymentTypeId] [int] NULL,
  [DepositRefundBankAccountId] [int] NULL,
  [DepositRefundCheckNumber] [varchar](15) NULL,
  [AchDate] [datetime] NULL,
  [IsPendingInformation] [bit] NULL,
  CONSTRAINT [PK_Contract] PRIMARY KEY CLUSTERED ([ContractId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[Contract]
  ADD CONSTRAINT [FK_Contract_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[Contract]
  ADD CONSTRAINT [FK_Contract_DepositBankAccountId] FOREIGN KEY ([DepositBankAccountId]) REFERENCES [dbo].[BankAccounts] ([BankAccountId])
GO

ALTER TABLE [dbo].[Contract]
  ADD CONSTRAINT [FK_Contract_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[Contract]
  ADD CONSTRAINT [FKContract_Apartments] FOREIGN KEY ([ApartmentId]) REFERENCES [dbo].[Apartments] ([ApartmentsId])
GO