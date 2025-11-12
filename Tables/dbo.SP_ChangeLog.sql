CREATE TABLE [dbo].[SP_ChangeLog] (
  [Id] [int] IDENTITY,
  [EventType] [nvarchar](50) NULL,
  [ObjectName] [nvarchar](255) NULL,
  [ObjectType] [nvarchar](100) NULL,
  [LoginName] [nvarchar](255) NULL,
  [HostName] [nvarchar](255) NULL,
  [EventDate] [datetime] NULL DEFAULT (getdate()),
  [DefinitionBefore] [nvarchar](max) NULL,
  [DefinitionAfter] [nvarchar](max) NULL,
  [TSQLCommand] [nvarchar](max) NULL,
  [DefinitionDiff] [nvarchar](max) NULL,
  [ProgramName] [nvarchar](255) NULL,
  PRIMARY KEY CLUSTERED ([Id])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO