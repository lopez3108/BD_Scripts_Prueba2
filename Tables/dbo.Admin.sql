CREATE TABLE [dbo].[Admin] (
  [AdminId] [int] IDENTITY,
  [UserId] [int] NOT NULL,
  [IsManager] [bit] NOT NULL CONSTRAINT [DF_Admin_IsManager] DEFAULT (0),
  CONSTRAINT [PK_Admin] PRIMARY KEY CLUSTERED ([AdminId])
)
ON [PRIMARY]
GO