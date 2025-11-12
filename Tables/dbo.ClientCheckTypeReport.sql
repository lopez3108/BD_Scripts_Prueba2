CREATE TABLE [dbo].[ClientCheckTypeReport] (
  [ClientCheckTypeReportId] [int] IDENTITY,
  [Code] [varchar](3) NULL,
  [Description] [varchar](20) NULL,
  [Translate] [varchar](50) NULL,
  CONSTRAINT [PK_ClientCheckTypeReport_ClientCheckTypeReportId] PRIMARY KEY CLUSTERED ([ClientCheckTypeReportId])
)
ON [PRIMARY]
GO