CREATE TABLE [dbo].[ReturnELSStatus] (
  [ReturnsELSStatusId] [int] IDENTITY,
  [Code] [varchar](3) NOT NULL,
  [Description] [varchar](30) NOT NULL,
  PRIMARY KEY CLUSTERED ([ReturnsELSStatusId])
)
ON [PRIMARY]
GO