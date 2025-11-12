CREATE TABLE [dbo].[PlateTypeOtherTruck] (
  [PlateTypeOtherTruckId] [int] IDENTITY,
  [Description] [varchar](30) NOT NULL,
  CONSTRAINT [PK_PlateTypeOtherTruck] PRIMARY KEY CLUSTERED ([PlateTypeOtherTruckId])
)
ON [PRIMARY]
GO