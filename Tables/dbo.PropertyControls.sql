CREATE TABLE [dbo].[PropertyControls] (
  [PropertyControlId] [int] IDENTITY,
  [Code] [varchar](5) NULL,
  [Name] [varchar](40) NOT NULL,
  [MonthNumberValid] [smallint] NULL CONSTRAINT [DF_PropertyControls_MonthNumberValid] DEFAULT (1),
  [CheckProperty ] [bit] NOT NULL DEFAULT (0),
  [CheckApartment] [bit] NOT NULL DEFAULT (0),
  CONSTRAINT [PK_PropertyControls] PRIMARY KEY CLUSTERED ([PropertyControlId])
)
ON [PRIMARY]
GO