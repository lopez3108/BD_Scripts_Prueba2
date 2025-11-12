CREATE TABLE [dbo].[InstructionChangeStatus] (
  [StatusId] [int] IDENTITY,
  [Code] [varchar](3) NOT NULL,
  [Description] [varchar](20) NOT NULL,
  CONSTRAINT [PK_IntructionChangeStatus] PRIMARY KEY CLUSTERED ([StatusId])
)
ON [PRIMARY]
GO