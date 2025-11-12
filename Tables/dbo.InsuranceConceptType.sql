CREATE TABLE [dbo].[InsuranceConceptType] (
  [InsuranceConceptTypeId] [int] IDENTITY,
  [Code] [varchar](5) NOT NULL,
  [Description] [varchar](30) NOT NULL,
  CONSTRAINT [PK_InsuranceConceptType] PRIMARY KEY CLUSTERED ([InsuranceConceptTypeId])
)
ON [PRIMARY]
GO