CREATE TABLE [dbo].[BillPayments] (
  [BillPaymentId] [int] IDENTITY,
  [ProviderId] [int] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [USD] [decimal](18, 2) NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [AgencyId] [int] NOT NULL,
  [Commission] [decimal](18, 2) NULL,
  [LastUpdatedBy] [int] NULL,
  [LastUpdatedOn] [datetime] NULL,
  [DetailedTransaction] [bit] NULL,
  CONSTRAINT [PK_BillPayments] PRIMARY KEY CLUSTERED ([BillPaymentId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[BillPayments]
  ADD CONSTRAINT [FK_BillPayments_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[BillPayments]
  ADD CONSTRAINT [FK_BillPayments_Providers] FOREIGN KEY ([ProviderId]) REFERENCES [dbo].[Providers] ([ProviderId])
GO

ALTER TABLE [dbo].[BillPayments]
  ADD CONSTRAINT [FK_BillPayments_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Indicate if the provider allowed detailes at the moment that transaction was created', 'SCHEMA', N'dbo', 'TABLE', N'BillPayments', 'COLUMN', N'DetailedTransaction'
GO