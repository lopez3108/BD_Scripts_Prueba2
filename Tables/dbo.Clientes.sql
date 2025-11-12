CREATE TABLE [dbo].[Clientes] (
  [ClienteId] [int] IDENTITY,
  [UsuarioId] [int] NOT NULL,
  [Foto] [varchar](max) NULL,
  [FingerPrint] [varchar](max) NULL,
  [FingerPrintTemplate] [varchar](max) NULL,
  [Note] [varchar](400) NULL,
  [Doc1Front] [varchar](max) NULL,
  [Doc1Back] [varchar](max) NULL,
  [Doc1Type] [int] NULL,
  [Doc1Number] [varchar](80) NULL,
  [Doc1Country] [int] NULL,
  [Doc1State] [varchar](50) NULL,
  [Doc1Expire] [datetime] NULL,
  [Doc2Front] [varchar](max) NULL,
  [Doc2Back] [varchar](max) NULL,
  [Doc2Type] [int] NULL,
  [Doc2Number] [varchar](80) NULL,
  [Doc2Country] [int] NULL,
  [Doc2State] [varchar](50) NULL,
  [Doc2Expire] [datetime] NULL,
  [IsNewClient] [bit] NULL CONSTRAINT [DF_Clientes_IsNewClient] DEFAULT (0),
  [RegistrationDate] [datetime] NULL,
  [PhoneValidated] [bit] NOT NULL CONSTRAINT [DF_Clientes_PhoneValidated] DEFAULT (0),
  [PhoneValidationCode] [varchar](4) NULL,
  [PhoneValidationExpirationDate] [datetime] NULL,
  [ClientStatusId] [int] NOT NULL,
  [ValidatedBy] [int] NULL,
  [ValidatedOn] [datetime] NULL,
  [CreatedBy] [int] NULL,
  [CreationDate] [datetime] NULL,
  [IsClientVIP] [bit] NULL CONSTRAINT [DF_Clientes_IsClientVIP] DEFAULT (0),
  [ReasonOne] [varchar](400) NULL,
  [ReasonTwo] [varchar](400) NULL,
  [VIPUserId] [int] NULL,
  [VIPAgencyId] [int] NULL,
  [VIPDate] [datetime] NULL,
  [CountContinuousChecks] [int] NULL CONSTRAINT [DF_Clientes_CountContinueChecks] DEFAULT (0),
  CONSTRAINT [PK_Clientes] PRIMARY KEY CLUSTERED ([ClienteId])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Clientes]
  ADD CONSTRAINT [FK_Clientes_Agencies] FOREIGN KEY ([VIPAgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[Clientes]
  ADD CONSTRAINT [FK_Clientes_DocumentStatus] FOREIGN KEY ([ClientStatusId]) REFERENCES [dbo].[DocumentStatus] ([DocumentStatusId])
GO

ALTER TABLE [dbo].[Clientes]
  ADD CONSTRAINT [FK_Clientes_Users] FOREIGN KEY ([VIPUserId]) REFERENCES [dbo].[Users] ([UserId])
GO

DECLARE @value SQL_VARIANT = CAST(N'' AS nvarchar(1))
EXEC sys.sp_addextendedproperty N'MS_Description', @value, 'SCHEMA', N'dbo', 'TABLE', N'Clientes'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'UserId del usuario que marco el cliente como VIP', 'SCHEMA', N'dbo', 'TABLE', N'Clientes', 'COLUMN', N'VIPUserId'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'AgencyId de la agencia que marco el cliente como VIP', 'SCHEMA', N'dbo', 'TABLE', N'Clientes', 'COLUMN', N'VIPAgencyId'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha en la que se marco el cliente como VIP', 'SCHEMA', N'dbo', 'TABLE', N'Clientes', 'COLUMN', N'VIPDate'
GO