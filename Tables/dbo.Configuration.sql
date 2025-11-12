CREATE TABLE [dbo].[Configuration] (
  [ConfigurationId] [int] IDENTITY,
  [MinimumFee] [decimal](18, 2) NOT NULL CONSTRAINT [DF_ConfigurationId_MinimumFee] DEFAULT (0),
  [MaximumFee] [decimal](18, 2) NOT NULL CONSTRAINT [DF_ConfigurationId_MaximumFee] DEFAULT (0),
  [MakerConfigurationUrl] [varchar](500) NULL,
  CONSTRAINT [PK_ConfigurationId] PRIMARY KEY CLUSTERED ([ConfigurationId])
)
ON [PRIMARY]
GO