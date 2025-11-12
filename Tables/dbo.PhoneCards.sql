CREATE TABLE [dbo].[PhoneCards] (
  [PhoneCardId] [int] IDENTITY,
  [Quantity] [int] NOT NULL,
  [PhoneCardsUsd] [decimal](18, 2) NOT NULL,
  [Commission] [decimal](18, 2) NOT NULL CONSTRAINT [DF_PhoneCards_Commission] DEFAULT (0),
  [CreatedBy] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [UpdatedBy] [int] NULL,
  [UpdatedOn] [datetime] NULL,
  CONSTRAINT [PK_PhoneCards] PRIMARY KEY CLUSTERED ([PhoneCardId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[PhoneCards]
  ADD CONSTRAINT [FK_PhoneCards_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[PhoneCards]
  ADD CONSTRAINT [FK_PhoneCards_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO