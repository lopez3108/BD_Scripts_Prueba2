CREATE TABLE [dbo].[TemplatesContract] (
  [TemplateContractId] [int] IDENTITY,
  [TitleTemplateContract] [varchar](100) NOT NULL,
  [TemplateContract] [varchar](max) NOT NULL,
  CONSTRAINT [PK_TemplatesContract_TemplateContractId] PRIMARY KEY CLUSTERED ([TemplateContractId])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO