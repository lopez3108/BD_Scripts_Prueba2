CREATE TABLE [dbo].[ReturnReason] (
  [ReturnReasonId] [int] IDENTITY,
  [Description] [varchar](50) NOT NULL,
  CONSTRAINT [PK_ReturnReason] PRIMARY KEY CLUSTERED ([ReturnReasonId])
)
ON [PRIMARY]
GO