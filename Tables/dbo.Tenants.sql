CREATE TABLE [dbo].[Tenants] (
  [TenantId] [int] IDENTITY,
  [Name] [varchar](80) NOT NULL,
  [Telephone] [varchar](12) NULL,
  [TypeId] [int] NULL,
  [DocNumber] [varchar](20) NULL,
  [Email] [varchar](100) NULL,
  [LastUpdatedOn] [datetime] NULL,
  [LastUpdatedBy] [int] NULL,
  [TelIsCheck] [bit] NULL,
  CONSTRAINT [PK__Tenants__2E9B47E195C12535] PRIMARY KEY CLUSTERED ([TenantId])
)
ON [PRIMARY]
GO