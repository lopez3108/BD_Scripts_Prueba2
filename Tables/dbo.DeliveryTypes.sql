CREATE TABLE [dbo].[DeliveryTypes] (
  [DeliveryTypeId] [int] IDENTITY,
  [Code] [varchar](10) NOT NULL,
  [Description] [varchar](30) NOT NULL,
  CONSTRAINT [PK_DeliveryTypes] PRIMARY KEY CLUSTERED ([DeliveryTypeId])
)
ON [PRIMARY]
GO