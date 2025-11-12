CREATE TABLE [dbo].[PassAccess] (
  [PassAccessId] [int] IDENTITY,
  [UserId] [int] NOT NULL,
  [OwnerUserId] [int] NOT NULL,
  [FromDate] [datetime] NOT NULL,
  [ToDate] [datetime] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  CONSTRAINT [PK_PassAccess] PRIMARY KEY CLUSTERED ([PassAccessId])
)
ON [PRIMARY]
GO