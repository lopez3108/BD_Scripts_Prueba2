CREATE TABLE [dbo].[Recommendations] (
  [RecommendationId] [int] IDENTITY,
  [ReviewXUserId] [int] NOT NULL,
  [Recommendation] [varchar](300) NOT NULL,
  CONSTRAINT [PK_Recommendations] PRIMARY KEY CLUSTERED ([RecommendationId])
)
ON [PRIMARY]
GO