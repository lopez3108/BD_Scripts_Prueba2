CREATE TABLE [dbo].[PaymentOthersAgentToAgent] (
  [PaymentOthersAgentToAgentId] [int] IDENTITY,
  [FromAgency] [int] NOT NULL,
  [ToAgency] [int] NOT NULL,
  [Date] [datetime] NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  [StatusId] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [DeletedOn] [datetime] NULL,
  [DeletedBy] [int] NULL,
  [Note] [varchar](180) NOT NULL,
  [CheckNumber] [varchar](15) NULL,
  [CheckDate] [datetime] NULL,
  [BankAccountId] [int] NULL,
  [CardBankId] [int] NULL,
  [AgencyId] [int] NULL,
  [MoneyOrderNumber] [varchar](20) NULL,
  [AchDate] [datetime] NULL,
  [ProviderCommissionPaymentTypeId] [int] NOT NULL,
  CONSTRAINT [PK_PaymentOthersAgentToAgent] PRIMARY KEY CLUSTERED ([PaymentOthersAgentToAgentId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[PaymentOthersAgentToAgent]
  ADD CONSTRAINT [FK_PaymentOthersAgentToAgent_Agencies] FOREIGN KEY ([FromAgency]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[PaymentOthersAgentToAgent]
  ADD CONSTRAINT [FK_PaymentOthersAgentToAgent_BankAccountId] FOREIGN KEY ([BankAccountId]) REFERENCES [dbo].[BankAccounts] ([BankAccountId])
GO

ALTER TABLE [dbo].[PaymentOthersAgentToAgent]
  ADD CONSTRAINT [FK_PaymentOthersAgentToAgent_CardBanks] FOREIGN KEY ([CardBankId]) REFERENCES [dbo].[CardBanks] ([CardBankId])
GO

ALTER TABLE [dbo].[PaymentOthersAgentToAgent]
  ADD CONSTRAINT [FK_PaymentOthersAgentToAgent_ProviderCommissionPaymentType] FOREIGN KEY ([ProviderCommissionPaymentTypeId]) REFERENCES [dbo].[ProviderCommissionPaymentTypes] ([ProviderCommissionPaymentTypeId])
GO

ALTER TABLE [dbo].[PaymentOthersAgentToAgent]
  ADD CONSTRAINT [FK_PaymentOthersAgentToAgent_ToAgencies] FOREIGN KEY ([ToAgency]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO