CREATE TABLE [dbo].[Emails] (
  [EmailsId] [int] IDENTITY,
  [Address] [varchar](80) NOT NULL,
  [Name] [varchar](100) NOT NULL,
  [Active] [bit] NOT NULL DEFAULT (0),
  CONSTRAINT [PK_Emails] PRIMARY KEY CLUSTERED ([EmailsId])
)
ON [PRIMARY]
GO

CREATE UNIQUE INDEX [U_Email]
  ON [dbo].[Emails] ([Address])
  ON [PRIMARY]
GO