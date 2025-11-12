CREATE TABLE [dbo].[InsuranceCommissionType] (
  [InsuranceCommissionTypeId] [int] IDENTITY,
  [Code] [varchar](5) NOT NULL,
  [Description] [varchar](20) NOT NULL,
  [CodeOrder] [tinyint] NOT NULL,
  CONSTRAINT [PK__Insuranc__96E5E959C0055845] PRIMARY KEY CLUSTERED ([InsuranceCommissionTypeId])
)
ON [PRIMARY]
GO