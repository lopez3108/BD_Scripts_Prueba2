SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[sp_GetAllNotesXInsuranceMonthlyPaymentId] (@InsuranceId Int, @InsuranceConceptTypeId Int )

AS 

Select 
Upper(nx.Note)   Note ,
nx.CreationDate,
Upper (u.Name) As CreatedByName,
nx.NotesXInsuranceId

From NotesXInsurance nx
JOIN users u
On u.UserId = nx.CreatedBy
where nx.InsuranceId = @InsuranceId AND nx.InsuranceConceptTypeId = @InsuranceConceptTypeId
GO