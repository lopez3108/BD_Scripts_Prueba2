CREATE TABLE [dbo].[NotesXInsurance] (
  [NotesXInsuranceId] [int] IDENTITY,
  [CreatedBy] [int] NOT NULL,
  [Note] [varchar](2000) NOT NULL,
  [CreationDate] [datetime] NOT NULL,
  [InsuranceId] [int] NOT NULL,
  [InsuranceConceptTypeId] [int] NULL,
  CONSTRAINT [PK__NotesXIn__30A306A07F2A554B] PRIMARY KEY CLUSTERED ([NotesXInsuranceId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[NotesXInsurance]
  ADD CONSTRAINT [FK_NotesXInsurance_InsuranceConceptType] FOREIGN KEY ([InsuranceConceptTypeId]) REFERENCES [dbo].[InsuranceConceptType] ([InsuranceConceptTypeId])
GO

ALTER TABLE [dbo].[NotesXInsurance]
  ADD CONSTRAINT [FK_NotesXInsurance_Users] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users] ([UserId])
GO