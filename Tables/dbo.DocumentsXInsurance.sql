CREATE TABLE [dbo].[DocumentsXInsurance] (
  [DocumentXInsuranceID] [int] IDENTITY,
  [InsuranceID] [int] NOT NULL,
  [FileName] [varchar](255) NOT NULL,
  [FileType] [varchar](50) NOT NULL,
  [UploadDate] [datetime] NULL,
  [LastUpdatedBy] [int] NULL
)
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Tabla que guarda los nombres de los archivos de Insurance ', 'SCHEMA', N'dbo', 'TABLE', N'DocumentsXInsurance'
GO