CREATE TABLE [dbo].[ZipCodes] (
  [ZipCode] [nvarchar](50) NOT NULL,
  [City] [nvarchar](255) NULL,
  [State] [nvarchar](255) NULL,
  [StateAbre] [nvarchar](255) NULL,
  [County] [nvarchar](255) NULL,
  [Latitude] [float] NULL,
  [Longitude] [float] NULL,
  CONSTRAINT [PK_ZipCodes] PRIMARY KEY CLUSTERED ([ZipCode])
)
ON [PRIMARY]
GO