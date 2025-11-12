CREATE TABLE [dbo].[ConfigFeesXProviderElsXProcess] (
  [ConfigurationFeesXProviderElsXProcessId] [int] IDENTITY,
  [ProviderElsId] [int] NOT NULL,
  [ProcessTypeId] [int] NOT NULL,
  [Fee1Default] [decimal](18, 2) NOT NULL,
  [FeeELS] [decimal](18, 2) NOT NULL,
  CONSTRAINT [PK_ConfigFeesXProviderElsXProcess] PRIMARY KEY CLUSTERED ([ConfigurationFeesXProviderElsXProcessId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[ConfigFeesXProviderElsXProcess]
  ADD CONSTRAINT [FK_ConfigFeesXProviderElsXProcess_ProcessTypes] FOREIGN KEY ([ProcessTypeId]) REFERENCES [dbo].[ProcessTypes] ([ProcessTypeId])
GO

ALTER TABLE [dbo].[ConfigFeesXProviderElsXProcess]
  ADD CONSTRAINT [FK_ConfigFeesXProviderElsXProcess_ProvidersEls] FOREIGN KEY ([ProviderElsId]) REFERENCES [dbo].[ProvidersEls] ([ProviderElsId])
GO