CREATE TABLE [dbo].[SerialsXReturn] (
  [SerialsId] [int] IDENTITY,
  [ReturnsELSId] [int] NOT NULL,
  [SerialNumber] [varchar](15) NOT NULL,
  CONSTRAINT [PK_SerialsXReturn] PRIMARY KEY CLUSTERED ([SerialsId])
)
ON [PRIMARY]
GO