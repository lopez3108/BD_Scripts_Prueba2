CREATE TABLE [dbo].[InsuranceCommissionPolicyTypeMovement] (
  [InsuranceCommissionPolicyTypeMovementId] [int] IDENTITY,
  [ProviderId] [int] NOT NULL,
  [PolicyTypeId] [int] NOT NULL,
  [InsuranceCommissionTypeId] [int] NOT NULL,
  [USD] [decimal](18, 2) NOT NULL,
  CONSTRAINT [PK_InsuranceCommissionTypeXProviderMovement] PRIMARY KEY CLUSTERED ([InsuranceCommissionPolicyTypeMovementId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[InsuranceCommissionPolicyTypeMovement]
  ADD CONSTRAINT [FK_InsuranceCommissionPolicyTypeMovement_PolicyType] FOREIGN KEY ([PolicyTypeId]) REFERENCES [dbo].[PolicyType] ([PolicyTypeId])
GO

ALTER TABLE [dbo].[InsuranceCommissionPolicyTypeMovement]
  ADD CONSTRAINT [FK_InsuranceCommissionPolicyTypeMovement_Providers] FOREIGN KEY ([ProviderId]) REFERENCES [dbo].[Providers] ([ProviderId])
GO

ALTER TABLE [dbo].[InsuranceCommissionPolicyTypeMovement]
  ADD CONSTRAINT [FK_InsuranceCommissionTypeXProviderMovement_InsuranceCommissionType] FOREIGN KEY ([InsuranceCommissionTypeId]) REFERENCES [dbo].[InsuranceCommissionType] ([InsuranceCommissionTypeId])
GO