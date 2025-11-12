CREATE TABLE [dbo].[VinPertmitStatus] (
  [VinPertmitTrpId] [int] IDENTITY,
  [Code] [varchar](3) NOT NULL,
  [Description] [varchar](15) NOT NULL,
  CONSTRAINT [PK_VinPertmitStatus] PRIMARY KEY CLUSTERED ([VinPertmitTrpId])
)
ON [PRIMARY]
GO