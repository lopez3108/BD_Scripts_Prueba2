CREATE TABLE [dbo].[SMSSent] (
  [SMSSentId] [int] IDENTITY,
  [SMSCategoryId] [int] NOT NULL,
  [Message] [varchar](500) NOT NULL,
  [CreatedBy] [int] NULL,
  [CreationDate] [datetime] NOT NULL,
  [AgencyId] [int] NULL,
  [Sent] [bit] NOT NULL,
  [Telephone] [varchar](15) NULL,
  [PropertyId] [int] NULL,
  CONSTRAINT [PK_SMSSent] PRIMARY KEY CLUSTERED ([SMSSentId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[SMSSent] WITH NOCHECK
  ADD CONSTRAINT [FK_SMSSent_SMSCategories] FOREIGN KEY ([SMSCategoryId]) REFERENCES [dbo].[SMSCategories] ([SMSCategoryId])
GO

ALTER TABLE [dbo].[SMSSent]
  ADD CONSTRAINT [FK_SMSSent_SMSSent] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[SMSSent]
  ADD CONSTRAINT [FK_SMSSent_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO