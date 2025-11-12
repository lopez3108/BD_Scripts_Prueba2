SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreateLendify]

@LendifyId INT,
@Name VARCHAR(60),
@Telephone VARCHAR(10),
--@LendifyStatusId INT,
@CreationDate DATETIME,
@CreatedBy INT,
@AgencyId INT
--@AprovedDate DATETIME = NULL,
--@AprovedBy INT = NULL

AS
    BEGIN

	DECLARE @LendifyStatusId INT
	SET @LendifyStatusId = (select LendifyStatusId from LendifyStatus where Code = 'C01')

	INSERT INTO [dbo].[Lendify]
           (Name
			,Telephone
			,LendifyStatusId
			,CreationDate
			,CreatedBy
			,AgencyId
			,AprovedDate
			,AprovedBy)
     VALUES
           (@Name
			,@Telephone
			,@LendifyStatusId
			,@CreationDate
			,@CreatedBy
			,@AgencyId
			,NULL
			,NULL)

	SELECT @@IDENTITY

END;
GO