CREATE TABLE [dbo].[Apartments] (
  [ApartmentsId] [int] IDENTITY,
  [PropertiesId] [int] NOT NULL,
  [Number] [varchar](10) NOT NULL,
  [Bathrooms] [int] NOT NULL,
  [Bedrooms] [int] NOT NULL,
  [Description] [varchar](500) NULL,
  [Size] [decimal](18, 2) NULL,
  [CreatedBy] [int] NULL,
  [CreationDate] [datetime] NULL,
  [LastUpdatedBy] [int] NULL,
  [LastUpdatedOn] [datetime] NULL,
  CONSTRAINT [PK_Apartments] PRIMARY KEY CLUSTERED ([ApartmentsId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[Apartments]
  ADD CONSTRAINT [FKAparments_Properties] FOREIGN KEY ([PropertiesId]) REFERENCES [dbo].[Properties] ([PropertiesId])
GO