CREATE TABLE [dbo].[Documents] (
  [DocumentByClientId] [int] IDENTITY,
  [DocumentId] [int] NOT NULL,
  [Doc1Front] [varchar](max) NULL,
  [Doc1Back] [varchar](max) NULL,
  [Doc1Type] [int] NULL,
  [Doc1Number] [varchar](80) NULL,
  [Doc1Country] [int] NULL,
  [Doc1State] [varchar](50) NULL,
  [Doc1Expire] [datetime] NULL,
  [ExpireDoc1] [bit] NULL CONSTRAINT [DF_Documents_ExpireDoc1] DEFAULT (0),
  [CreatedDate] [datetime] NULL,
  [CreatedBy] [int] NULL,
  [UpdatedOn] [datetime] NULL,
  [UpdatedBy] [int] NULL,
  [DocumentStatusId1] [int] NULL,
  [AgencyId] [int] NULL,
  CONSTRAINT [PK_Documents_1] PRIMARY KEY CLUSTERED ([DocumentByClientId])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Documents]
  ADD CONSTRAINT [FK_Documents_TypeID] FOREIGN KEY ([Doc1Type]) REFERENCES [dbo].[TypeID] ([TypeId])
GO