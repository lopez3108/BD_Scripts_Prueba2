CREATE TABLE [dbo].[Checks] (
  [CheckId] [int] IDENTITY,
  [ClientId] [int] NOT NULL,
  [CheckTypeId] [int] NULL CONSTRAINT [DF_Checks_CheckType] DEFAULT (1),
  [CashierId] [int] NOT NULL,
  [AgencyId] [int] NULL,
  [CheckFront] [varchar](200) NULL,
  [CheckBack] [varchar](200) NULL,
  [DateCashed] [datetime] NOT NULL,
  [Maker] [int] NOT NULL,
  [Amount] [decimal](18, 2) NOT NULL,
  [Fee] [decimal](18, 2) NOT NULL,
  [Number] [varchar](50) NULL,
  [Account] [varchar](50) NOT NULL,
  [Routing] [varchar](50) NULL,
  [DateCheck] [datetime] NULL,
  [ValidatedBy] [int] NULL,
  [LastUpdatedBy] [int] NULL,
  [LastUpdatedOn] [datetime] NULL,
  [ValidatedRangeBy] [int] NULL,
  [ValidatedRoutingBy] [int] NULL,
  [ValidatedMaxAmountBy] [int] NULL,
  [ValidatedCheckDateBy] [int] NULL CONSTRAINT [DF_Checks_ValidatedCheckDateBy] DEFAULT ('0'),
  [ValidatedPhoneBy] [int] NULL,
  [ValidatedMakerBy] [int] NULL,
  [CheckStatusId] [int] NOT NULL,
  [ValidateCheckTypeBy] [int] NULL,
  [ValidatedPostdatedChecksBy] [int] NULL,
  [ValidatedRoutingByRightCashier ] [int] NULL,
  CONSTRAINT [PK_Checks] PRIMARY KEY CLUSTERED ([CheckId])
)
ON [PRIMARY]
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE UNIQUE INDEX [IX_Checks]
  ON [dbo].[Checks] ([Account], [Number])
  WHERE ([Account] IS NOT NULL AND [Number] IS NOT NULL)
  ON [PRIMARY]
GO

ALTER TABLE [dbo].[Checks]
  ADD CONSTRAINT [FK_Checks_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[Checks]
  ADD CONSTRAINT [FK_Checks_Cashiers] FOREIGN KEY ([CashierId]) REFERENCES [dbo].[Cashiers] ([CashierId])
GO

ALTER TABLE [dbo].[Checks]
  ADD CONSTRAINT [FK_Checks_CheckTypes] FOREIGN KEY ([CheckTypeId]) REFERENCES [dbo].[CheckTypes] ([CheckTypeId])
GO

ALTER TABLE [dbo].[Checks]
  ADD CONSTRAINT [FK_Checks_Clientes] FOREIGN KEY ([ClientId]) REFERENCES [dbo].[Clientes] ([ClienteId])
GO

ALTER TABLE [dbo].[Checks]
  ADD CONSTRAINT [FK_Checks_DocumentStatus] FOREIGN KEY ([CheckStatusId]) REFERENCES [dbo].[DocumentStatus] ([DocumentStatusId])
GO

ALTER TABLE [dbo].[Checks]
  ADD CONSTRAINT [FK_Checks_Makers] FOREIGN KEY ([Maker]) REFERENCES [dbo].[Makers] ([MakerId])
GO

DECLARE @value SQL_VARIANT = CAST(N'' AS nvarchar(1))
EXEC sys.sp_addextendedproperty N'MS_Description', @value, 'SCHEMA', N'dbo', 'TABLE', N'Checks'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Creation date', 'SCHEMA', N'dbo', 'TABLE', N'Checks', 'COLUMN', N'DateCashed'
GO