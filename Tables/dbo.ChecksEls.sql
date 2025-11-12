CREATE TABLE [dbo].[ChecksEls] (
  [CheckElsId] [int] IDENTITY,
  [ProviderTypeId] [int] NOT NULL,
  [CheckId] [int] NULL,
  [Amount] [decimal](18, 2) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [ValidatedOn] [datetime] NULL,
  [ValidatedBy] [int] NULL,
  [Fee] [decimal](18, 2) NOT NULL CONSTRAINT [DF_ChecksEls_Fee] DEFAULT (0),
  [CheckDate] [datetime] NOT NULL CONSTRAINT [DF_ChecksEls_CheckDate] DEFAULT (0),
  [ClientId] [int] NULL,
  [FromRegisterApp] [bit] NULL CONSTRAINT [DF_ChecksEls_FromRegisterApp] DEFAULT (0),
  [CheckNumber] [varchar](50) NULL,
  [Account] [varchar](30) NULL,
  [Routing] [varchar](30) NULL,
  [MakerId] [int] NULL,
  [ValidatedRoutingBy] [int] NULL,
  [ValidatedRangeBy] [int] NULL,
  [ValidatedMaxAmountBy] [int] NULL,
  [ValidatedCheckDateBy] [int] NULL CONSTRAINT [DF_ChecksEls_ValidatedBy1] DEFAULT ('0'),
  [ValidatedPostdatedChecksBy] [int] NULL,
  [LastUpdatedBy] [int] NULL,
  [LastUpdatedOn] [datetime] NULL,
  [LotNumber] [smallint] NULL,
  [PaymentChecksAgentToAgentId] [int] NULL,
  [ProccesCheckReturned] [bit] NULL CONSTRAINT [DF_ChecksEls_ProccesCheckReturned] DEFAULT (0),
  [CheckClientIdGuidGroup] [varchar](100) NULL,
  [IsCheckParent] [bit] NULL,
  [ClientTelephone] [varchar](20) NULL,
  [ValidateCheckFraudAccountBy] [int] NULL,
  [ValidateCheckFraudCheckNumberBy] [int] NULL,
  [ValidateCheckFraudMakerBy] [int] NULL,
  [ValidateCheckFraudFileNumberBy] [int] NULL,
  [ValidateCheckFraudClientBy] [int] NULL,
  [ValidateCheckFraudClientTelephoneBy] [int] NULL,
  [ValidateCheckFraudAddressBy] [int] NULL,
  [ValidateCheckFraudIdentificacionNumberBy] [int] NULL,
  [ValidateCheckFraudAccountSafeBy] [int] NULL,
  [ValidateCheckClientTelBy] [int] NULL,
  [providerBatch] [varchar](50) NULL,
  CONSTRAINT [PK_ChecksEls] PRIMARY KEY CLUSTERED ([CheckElsId])
)
ON [PRIMARY]
GO

CREATE INDEX [IDX_ChecksEls_CreatedBy]
  ON [dbo].[ChecksEls] ([CreatedBy])
  INCLUDE ([ProviderTypeId], [CheckId], [Amount], [CreationDate], [AgencyId], [Fee], [CheckDate], [ClientId], [CheckNumber], [Account], [Routing], [MakerId], [LastUpdatedBy], [LastUpdatedOn], [IsCheckParent])
  ON [PRIMARY]
GO

ALTER TABLE [dbo].[ChecksEls]
  ADD CONSTRAINT [FK_ChecksEls_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[ChecksEls] WITH NOCHECK
  ADD CONSTRAINT [FK_ChecksEls_Checks] FOREIGN KEY ([CheckId]) REFERENCES [dbo].[Checks] ([CheckId])
GO

ALTER TABLE [dbo].[ChecksEls]
  ADD CONSTRAINT [FK_ChecksEls_CheckTypes] FOREIGN KEY ([ProviderTypeId]) REFERENCES [dbo].[ProviderTypes] ([ProviderTypeId])
GO

ALTER TABLE [dbo].[ChecksEls] WITH NOCHECK
  ADD CONSTRAINT [FK_ChecksEls_PaymentChecksAgentToAgent] FOREIGN KEY ([PaymentChecksAgentToAgentId]) REFERENCES [dbo].[PaymentChecksAgentToAgent] ([PaymentChecksAgentToAgentId]) NOT FOR REPLICATION
GO

ALTER TABLE [dbo].[ChecksEls]
  ADD CONSTRAINT [FK_ChecksEls_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Este campo identifica cuando el check els es un cash check, por lo tanto nos dice el checkid del check parent', 'SCHEMA', N'dbo', 'TABLE', N'ChecksEls', 'COLUMN', N'CheckId'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Este campo se usa para saber si el cheque fue procesado y en que fecha se hizo', 'SCHEMA', N'dbo', 'TABLE', N'ChecksEls', 'COLUMN', N'ValidatedOn'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Este campo se usa para saber si el cheque fue procesado y quien lo hizo', 'SCHEMA', N'dbo', 'TABLE', N'ChecksEls', 'COLUMN', N'ValidatedBy'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Número de lote donde fue procesado el cheque por fecha y por userId', 'SCHEMA', N'dbo', 'TABLE', N'ChecksEls', 'COLUMN', N'LotNumber'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fk con la tabla PaymentChecksAgentToAgentId para saber el lote donde se proceso el chque', 'SCHEMA', N'dbo', 'TABLE', N'ChecksEls', 'COLUMN', N'PaymentChecksAgentToAgentId'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Este campo indica si un cheque que había sido procesado, fue revertido y queda marcado como un cheque rebotado por siempre, así se vuelva a procesar en un nuevo lote.', 'SCHEMA', N'dbo', 'TABLE', N'ChecksEls', 'COLUMN', N'ProccesCheckReturned'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Este campo sirve para identificar cuando se crea un check desde el daily y agrupar todos los cheques del mismo movimiento', 'SCHEMA', N'dbo', 'TABLE', N'ChecksEls', 'COLUMN', N'CheckClientIdGuidGroup'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Esta columna identifica al cheque els como el primer cash check, por lo tanto se vincula ambos cheques por siempre y cualquier cambio que se haga en uno debe reflejarse en el otro', 'SCHEMA', N'dbo', 'TABLE', N'ChecksEls', 'COLUMN', N'IsCheckParent'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Número de lote que da el provider, cuando se procesan los cheques.', 'SCHEMA', N'dbo', 'TABLE', N'ChecksEls', 'COLUMN', N'providerBatch'
GO