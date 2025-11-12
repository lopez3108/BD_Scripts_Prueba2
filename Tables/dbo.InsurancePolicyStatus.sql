CREATE TABLE [dbo].[InsurancePolicyStatus] (
  [InsurancePolicyStatusId] [int] IDENTITY,
  [Code] [varchar](4) NOT NULL,
  [Description] [varchar](20) NOT NULL,
  PRIMARY KEY CLUSTERED ([InsurancePolicyStatusId])
)
ON [PRIMARY]
GO