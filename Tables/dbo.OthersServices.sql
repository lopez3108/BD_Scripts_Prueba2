CREATE TABLE [dbo].[OthersServices] (
  [OtherId] [int] IDENTITY,
  [Name] [varchar](50) NOT NULL,
  [AcceptNegative] [bit] NOT NULL CONSTRAINT [DF_OthersServices_AcceptNegative] DEFAULT (0),
  [AcceptDetails] [bit] NOT NULL CONSTRAINT [DF_Table_1_AcceptNegative1] DEFAULT (0),
  [Active] [bit] NOT NULL DEFAULT (0),
  CONSTRAINT [PK_OthersServices] PRIMARY KEY CLUSTERED ([OtherId])
)
ON [PRIMARY]
GO