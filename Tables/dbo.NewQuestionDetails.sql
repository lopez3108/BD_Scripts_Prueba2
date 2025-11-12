CREATE TABLE [dbo].[NewQuestionDetails] (
  [NewQuestionId] [int] IDENTITY,
  [NewsId] [int] NOT NULL,
  [Question] [varchar](400) NOT NULL,
  [Yes] [bit] NOT NULL CONSTRAINT [DF_NewQuestionDetails_Yes] DEFAULT (0),
  CONSTRAINT [PK_NewQuestionDetails] PRIMARY KEY CLUSTERED ([NewQuestionId])
)
ON [PRIMARY]
GO