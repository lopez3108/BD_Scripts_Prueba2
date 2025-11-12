CREATE TABLE [dbo].[PlateTypeTrailer] (
  [PlateTypeTrailerId] [int] IDENTITY,
  [Description] [varchar](30) NOT NULL,
  CONSTRAINT [PK_PlateTypeTrailer] PRIMARY KEY CLUSTERED ([PlateTypeTrailerId])
)
ON [PRIMARY]
GO