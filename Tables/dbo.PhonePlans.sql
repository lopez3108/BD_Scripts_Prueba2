CREATE TABLE [dbo].[PhonePlans] (
  [PhonePlanId] [int] IDENTITY,
  [Description] [varchar](30) NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  [Active] [bit] NOT NULL CONSTRAINT [DF_PhonePlans_Active] DEFAULT (1),
  CONSTRAINT [PK_PhonePlans] PRIMARY KEY CLUSTERED ([PhonePlanId])
)
ON [PRIMARY]
GO