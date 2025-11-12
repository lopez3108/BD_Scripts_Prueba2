CREATE TABLE [dbo].[Insurance] (
  [InsuranceId] [int] IDENTITY,
  [Name] [varchar](40) NOT NULL,
  [Telephone] [varchar](50) NOT NULL,
  [URL] [varchar](400) NULL,
  CONSTRAINT [PK_Insurance] PRIMARY KEY CLUSTERED ([InsuranceId])
)
ON [PRIMARY]
GO