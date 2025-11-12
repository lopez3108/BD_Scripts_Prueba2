CREATE TABLE [dbo].[PropertiesCityCodeFiles] (
  [PropertiesCityCodeFilesId] [int] IDENTITY,
  [Filename] [varchar](200) NULL,
  [LastUpdatedBy] [int] NOT NULL,
  [LastUpdatedOn] [datetime] NOT NULL,
  PRIMARY KEY CLUSTERED ([PropertiesCityCodeFilesId])
)
ON [PRIMARY]
GO