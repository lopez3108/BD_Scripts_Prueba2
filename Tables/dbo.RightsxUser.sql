CREATE TABLE [dbo].[RightsxUser] (
  [RightsxUserId] [int] IDENTITY,
  [UserId] [int] NOT NULL,
  [Rights] [varchar](400) NOT NULL,
  CONSTRAINT [PK_RightsxUser] PRIMARY KEY CLUSTERED ([RightsxUserId])
)
ON [PRIMARY]
GO