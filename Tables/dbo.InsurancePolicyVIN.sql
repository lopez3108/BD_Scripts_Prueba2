CREATE TABLE [dbo].[InsurancePolicyVIN] (
  [InsurancePolicyVINId] [int] IDENTITY,
  [InsurancePolicyId] [int] NOT NULL,
  [VINNumber] [varchar](30) NOT NULL,
  PRIMARY KEY CLUSTERED ([InsurancePolicyVINId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[InsurancePolicyVIN]
  ADD CONSTRAINT [FK_InsurancePolicyVIN_InsurancePolicy] FOREIGN KEY ([InsurancePolicyId]) REFERENCES [dbo].[InsurancePolicy] ([InsurancePolicyId])
GO