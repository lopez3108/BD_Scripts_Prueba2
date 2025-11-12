CREATE TABLE [dbo].[ExtraFund] (
  [ExtraFundId] [int] IDENTITY,
  [CreationDate] [datetime] NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [LastUpdated] [datetime] NULL,
  [LastUpdatedBy] [int] NULL,
  [AgencyId] [int] NOT NULL,
  [AssignedTo] [int] NULL,
  [CashAdmin] [bit] NOT NULL CONSTRAINT [DF_ExtraFund_CashAdmin] DEFAULT (0),
  [IsCashier] [bit] NOT NULL DEFAULT (0),
  [Reason] [varchar](50) NULL,
  [completed] [bit] NULL DEFAULT (0),
  [CompletedBy] [varchar](50) NULL,
  [CompletedOn] [datetime] NULL,
  CONSTRAINT [PK_ExtraFund] PRIMARY KEY CLUSTERED ([ExtraFundId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[ExtraFund]
  ADD CONSTRAINT [FK_ExtraFund_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[ExtraFund]
  ADD CONSTRAINT [FK_ExtraFund_Users1] FOREIGN KEY ([LastUpdatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[ExtraFund] WITH NOCHECK
  ADD CONSTRAINT [FK_ExtraFund_Users2] FOREIGN KEY ([AssignedTo]) REFERENCES [dbo].[Users] ([UserId])
GO

ALTER TABLE [dbo].[ExtraFund]
  NOCHECK CONSTRAINT [FK_ExtraFund_Users2]
GO

DECLARE @value SQL_VARIANT = CAST(N'' AS nvarchar(1))
EXEC sys.sp_addextendedproperty N'MS_Description', @value, 'SCHEMA', N'dbo', 'TABLE', N'ExtraFund'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Dinero que se transfiere a un admin desde la seccion extrafund del daily de un cashier.', 'SCHEMA', N'dbo', 'TABLE', N'ExtraFund', 'COLUMN', N'CashAdmin'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Dinero que se transfiere desde un cajero a otro.', 'SCHEMA', N'dbo', 'TABLE', N'ExtraFund', 'COLUMN', N'IsCashier'
GO