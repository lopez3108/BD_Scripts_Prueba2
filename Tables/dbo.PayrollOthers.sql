CREATE TABLE [dbo].[PayrollOthers] (
  [PayrollOthersId] [int] IDENTITY,
  [PayrollId] [int] NOT NULL,
  [PayrollOtherTypesId] [int] NOT NULL,
  [Usd] [decimal](18, 2) NOT NULL,
  [AgencyId] [int] NULL,
  [Description] [varchar](150) NOT NULL,
  [FileName] [varchar](255) NULL,
  CONSTRAINT [PK_PayrollOthers] PRIMARY KEY CLUSTERED ([PayrollOthersId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[PayrollOthers]
  ADD CONSTRAINT [FK_PayrollOthers_Agencies] FOREIGN KEY ([AgencyId]) REFERENCES [dbo].[Agencies] ([AgencyId])
GO

ALTER TABLE [dbo].[PayrollOthers]
  ADD CONSTRAINT [FK_PayrollOthers_PayrollOtherTypes] FOREIGN KEY ([PayrollOtherTypesId]) REFERENCES [dbo].[PayrollOtherTypes] ([PayrollOtherTypesId])
GO

ALTER TABLE [dbo].[PayrollOthers]
  ADD CONSTRAINT [FK_PayrollOthers_Payrolls] FOREIGN KEY ([PayrollId]) REFERENCES [dbo].[Payrolls] ([PayrollId])
GO