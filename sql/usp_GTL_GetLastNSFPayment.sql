SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    /*********************************************************************************************
     * PROCEDURE:	[usp_GTL_GetLastNSFPayment]
     * DESCRIPTION:	Get the Last NSF Payment That Occurred On a policy
     * CREATE  BY:   Ed Rheingans
     * CREATE  DATE: 28JULY2025
     * ALTER        
     ********************************************************************************************/
    ALTER PROCEDURE [dbo].[usp_GTL_GetLastNSFPayment] @pCompanyCode char(2),
    @pPolicyNo nchar(12) AS BEGIN -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
SET NOCOUNT ON;
DECLARE @identifying_alpha nchar(14)
SET @identifying_alpha = LTRIM(RTRIM(@pCompanyCode)) + LTRIM(RTRIM(@pPolicyNo))
SELECT TOP 1
    PPOLC.PAID_TO_DATE,
    PACTG.COMPANY_CODE,
    PACTG.POLICY_NUMBER,
    XPRINT_REQUEST.FORM_SUB_TYPE AS RETURN_REASON_CD
FROM lifepro.dbo.PACTG PACTG WITH(NOLOCK)
    LEFT JOIN lifepro.dbo.PPCOMDES COMDES ON 
        PACTG.COMPANY_CODE = COMDES.COMPANY_CODE_TBL 
        AND PACTG.POLICY_NUMBER = COMDES.DESCRIPTIVE_TEXT 
        AND PACTG.CONTROL_NUMBER = COMDES.CONTROL_NUMBER
    JOIN XPRINT_REQUEST ON 
        PACTG.POLICY_NUMBER = XPRINT_REQUEST.POLICY_NUMBER
    JOIN PPOLC ON PPOLC.POLICY_NUMBER = PACTG.POLICY_NUMBER
WHERE PACTG.COMPANY_CODE = @pCompanyCode
    AND PACTG.POLICY_NUMBER = @pPolicyNo
    AND PACTG.BENEFIT_SEQ = 01
    AND PACTG.CONTROL_NUMBER = (
        Select TOP 1 CONTROL_NUMBER From lifepro.dbo.PACTG A1 with(nolock)
        Where A1.POLICY_NUMBER = @pPolicyNo
        And A1.CREDIT_ACCOUNT = '112600'
        And Not Exists(Select A2.* From lifepro.dbo.PACTG A2 with(nolock)
                        Where A2.POLICY_NUMBER = A1.POLICY_NUMBER
                        And A2.CREDIT_ACCOUNT like '3%'
                        And (A2.DATE_ADDED > A1.DATE_ADDED Or (A2.DATE_ADDED = A1.DATE_ADDED And A2.TIME_ADDED > A1.TIME_ADDED)))
        ORDER BY A1.DATE_ADDED DESC, A1.TIME_ADDED DESC, A1.CONTROL_NUMBER DESC
    )
    AND XPRINT_REQUEST.FORM_SUB_TYPE LIKE 'NSF%'
ORDER BY PACTG.DATE_ADDED DESC, PACTG.TIME_ADDED DESC, PACTG.CONTROL_NUMBER DESC;
END
GO