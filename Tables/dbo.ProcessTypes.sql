CREATE TABLE [dbo].[ProcessTypes] (
  [ProcessTypeId] [int] IDENTITY,
  [Code] [varchar](10) NOT NULL,
  [Description] [varchar](100) NOT NULL,
  [DefaultUsd] [decimal](18, 2) NULL,
  [DefaultFee] [decimal](18, 2) NULL,
  [DefaultFeeILDOR] [decimal](18, 2) NULL,
  [DefaultFeeILSOS] [decimal](18, 2) NULL,
  [DefaultFeeOther] [decimal](18, 2) NULL,
  [ProcessAuto] [bit] NOT NULL CONSTRAINT [DF_ProcessTypes_ProcessAuto] DEFAULT (0),
  [Order] [int] NOT NULL,
  CONSTRAINT [PK_ProcessTypes] PRIMARY KEY CLUSTERED ([ProcessTypeId])
)
ON [PRIMARY]
GO