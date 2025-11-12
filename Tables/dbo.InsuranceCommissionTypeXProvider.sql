CREATE TABLE [dbo].[InsuranceCommissionTypeXProvider] (
  [InsuranceCommissionTypeXProvider] [int] IDENTITY,
  [ProviderId] [int] NOT NULL,
  [InsuranceCommissionTypeId] [int] NOT NULL,
  [USD] [decimal](18, 2) NOT NULL,
  [FeeService] [decimal](18, 2) NOT NULL,
  PRIMARY KEY CLUSTERED ([InsuranceCommissionTypeXProvider])
)
ON [PRIMARY]
GO