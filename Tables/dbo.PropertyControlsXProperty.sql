CREATE TABLE [dbo].[PropertyControlsXProperty] (
  [PropertyControlsXPropertyId] [int] IDENTITY,
  [PropertyControlId] [int] NOT NULL,
  [PropertiesId] [int] NULL,
  [ApartmentsId] [int] NULL,
  [Date] [datetime] NOT NULL,
  [Note] [varchar](100) NULL,
  [Completed] [bit] NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [CreatedBy] [int] NOT NULL,
  [Pending] [bit] NOT NULL CONSTRAINT [DF_PropertyControlsXProperty_Pending] DEFAULT (1),
  [CompletedBy] [int] NULL,
  [CompletedDate] [datetime] NULL,
  [ValidThrough] [datetime] NULL,
  CONSTRAINT [PK_PropertyControlsXProperty] PRIMARY KEY CLUSTERED ([PropertyControlsXPropertyId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[PropertyControlsXProperty]
  ADD CONSTRAINT [FK_PropertyControlsXProperty_PropertyControls] FOREIGN KEY ([PropertyControlId]) REFERENCES [dbo].[PropertyControls] ([PropertyControlId])
GO