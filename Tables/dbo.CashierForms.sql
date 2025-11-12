CREATE TABLE [dbo].[CashierForms] (
  [CashierFormsId] [int] IDENTITY,
  [w4] [varchar](1000) NULL,
  [Confidentiality] [varchar](1000) NULL,
  [DirectDeposit] [varchar](1000) NULL,
  [BiometricInformation] [varchar](1000) NULL,
  [ComplianceOfficer] [varchar](1000) NULL,
  [EmploymentApplication] [varchar](1000) NULL,
  [EmploymentWarning] [varchar](1000) NULL,
  [PaidSickTime] [varchar](1000) NULL
)
ON [PRIMARY]
GO