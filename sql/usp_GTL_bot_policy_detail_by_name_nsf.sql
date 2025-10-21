USE [lifepro]
GO

/****** Object:  StoredProcedure [dbo].[usp_GTL_bot_policy_detail_by_name]    Script Date: 9/30/2025 11:17:50 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




/******************************************************************************
 * PROCEDURE:	usp_GTL_bot_policy_detail_by_name
 * DESCRIPTION:	Get policy detail by name,dob,ssn or zip
 *             	.
 * CREATE BY:	Richard Black
 * CREATE DATE: 4/24/2024
 * 
 * REVISIONS:
 *
  ******************************************************************************/
ALTER PROCEDURE [dbo].[usp_GTL_bot_policy_detail_by_name]
@AgentNumber char(8),
@last_name varchar(40),
@dob datetime,
@zipcode char(5),
@ssn char(4)



AS
BEGIN
	set @last_name = upper(@last_name)

    DECLARE @company_code CHAR (2)
    DECLARE @agent_nbr CHAR (12)
    DECLARE @market_code CHAR (10)
    DECLARE @agent_level CHAR (2)
    DECLARE @stop_date VARCHAR (8)
    DECLARE @rc INT
    DECLARE @h_id INT
    DECLARE @cur_level INT

    CREATE TABLE #hier_small 
    (	company_code CHAR (2) NOT NULL ,
    	h_agent_nbr CHAR (12) NOT NULL ,
    	agent_nbr CHAR (12) NOT NULL ,
    	market_code CHAR (10) NOT NULL ,
    	agent_level CHAR (2) NOT NULL,
        stop_date VARCHAR (8),
        cur_level INT NOT NULL)


 
    CREATE TABLE #hier_small_2  
    (	company_code CHAR (2) NOT NULL ,
    	h_agent_nbr CHAR (12) NOT NULL ,
    	agent_nbr CHAR (12) NOT NULL ,
    	market_code CHAR (10) NOT NULL ,
    	agent_level CHAR (2) NOT NULL,
        stop_date VARCHAR (8),
        cur_level INT NOT NULL)

  
	
    CREATE TABLE #hier_final  
    (	company_code CHAR (2) NOT NULL ,
    	h_agent_nbr CHAR (12) NOT NULL ,
    	agent_nbr CHAR (12) NOT NULL ,
    	market_code CHAR (10) NOT NULL ,
    	agent_level CHAR (2) NOT NULL,
        stop_date VARCHAR (8),
        cur_level INT NOT NULL)

  
    SET @h_id = 0
    SET @company_code = LEFT(@AgentNumber, 2)

    SET @cur_level = 0	

    INSERT INTO #hier_small
    SELECT  TOP 1 
            COMPANY_CODE,
            HIERARCHY_AGENT,
            AGENT_NUM,
            MARKET_CODE,
            AGENT_LEVEL,
            STOP_DATE,
            @cur_level
    FROM PHIER_AGENT_HIERARCHY
    WHERE COMPANY_CODE = @company_code and
          AGENT_NUM = @AgentNumber and STOP_DATE ='99999999'

    CREATE  INDEX [idx_hier_small] ON #hier_small(company_code,h_agent_nbr) 

    SET @cur_level = 1	

    INSERT INTO #hier_small
    SELECT  DISTINCT COMPANY_CODE,
            HIERARCHY_AGENT,
            AGENT_NUM,
            MARKET_CODE,
            AGENT_LEVEL,
            STOP_DATE,
            @cur_level
    FROM PHIER_AGENT_HIERARCHY a
    WHERE COMPANY_CODE = @company_code and
          HIERARCHY_AGENT = @AgentNumber  
          --and statmnt_ind = 'X' 
	    and  STOP_DATE = (SELECT MAX(STOP_DATE) 
    				FROM PHIER_AGENT_HIERARCHY b
    				WHERE b.COMPANY_CODE = @company_code and
          				b.HIERARCHY_AGENT = @AgentNumber and
                                        a.AGENT_NUM = b.AGENT_NUM and
					a.MARKET_CODE = b.MARKET_CODE and
					a.AGENT_LEVEL = b.AGENT_LEVEL)  
          and a.STOP_DATE ='99999999'

    SET @rc = @@rowcount

    WHILE @rc <> 0
    BEGIN

    INSERT INTO #hier_final
    SELECT  *
    FROM #hier_small 

    SET @cur_level = @cur_level + 1	

    INSERT INTO #hier_small_2
    SELECT  DISTINCT a.COMPANY_CODE,
            a.HIERARCHY_AGENT,
            a.AGENT_NUM,
            a.MARKET_CODE,
            a.AGENT_LEVEL,
            a.STOP_DATE,
           @cur_level
    FROM #hier_small b join PHIER_AGENT_HIERARCHY a   on
          a.COMPANY_CODE = b.company_code collate SQL_Latin1_General_CP1_CI_AS and
          a.HIERARCHY_AGENT = b.agent_nbr collate SQL_Latin1_General_CP1_CI_AS and
          a.HIER_MARKET_CODE = b.market_code collate SQL_Latin1_General_CP1_CI_AS and
          a.HIER_AGENT_LEVEL = b.agent_level collate SQL_Latin1_General_CP1_CI_AS --and
          --statmnt_ind = 'X'
and a.STOP_DATE ='99999999'

    DELETE FROM #hier_small

    INSERT INTO #hier_small
    SELECT  *
    FROM #hier_small_2 

    DELETE FROM #hier_small_2

        SET @rc = @@rowcount
    END

    INSERT INTO #hier_final
    SELECT  TOP 1 
            COMPANY_CODE,
            HIERARCHY_AGENT,
            AGENT_NUM,
            MARKET_CODE,
            AGENT_LEVEL,
            STOP_DATE,
            0
    FROM PHIER_AGENT_HIERARCHY
    WHERE COMPANY_CODE = @company_code and
          AGENT_NUM = @AgentNumber and STOP_DATE ='99999999'


insert into #hier_final(company_code,h_agent_nbr,agent_nbr,market_code,agent_level,cur_level) values(left(@AgentNumber,2),@AgentNumber,@AgentNumber,'XX','00',0)

    CREATE  INDEX [idx_hier_final] ON #hier_final(company_code,h_agent_nbr)

	--select * from #hier_final



select 
--PPOLC.POLICY_NUMBER as Policy,
PPOLC.POLICY_NUMBER as POLICY_NUMBER,
--PPOLC.PRODUCT_CODE,
--PPRDF.DESCRIPTION as [Plan],
PPRDF.DESCRIPTION ,
--rtrim(PNAME.INDIVIDUAL_FIRST) + ' ' + rtrim(PNAME.INDIVIDUAL_LAST) as Insured,
rtrim(PNAME.INDIVIDUAL_FIRST) + ' ' + rtrim(PNAME.INDIVIDUAL_LAST) as Insured_Name,
case PPOLC.CONTRACT_CODE when 'A' then 'Active'
	when 'T' then 'Terminated'
	when 'P' then 'Pending'
	when 'S' then 'Suspended'
	else 'Unknown' end as Status,
right(PTRNS_SENSITIVE_DATA_TRANSLATE.DECRYPTED_VALUE,4) as Insured_SSN,
--PNAME.DATE_OF_BIRTH,
case when isdate(PNAME.DATE_OF_BIRTH)=0  then '01/01/1900' else CONVERT(datetime,CAST(PNAME.DATE_OF_BIRTH as CHAR(8)),112) end as Insured_DOB,
PNAME.SEX_CODE as Insured_Gender,
coalesce(PPBEN_POLICY_BENEFITS_TYPES_BA_OR.ISSUE_AGE,0) as Insured_Issue_Age,
coalesce(PPBEN_POLICY_BENEFITS_TYPES_BA_OR.ISSUE_STATE,'') as Issue_State,
case when isdate(PPOLC.APPLICATION_DATE)=0  then '01/01/1900' else CONVERT(datetime,CAST(PPOLC.APPLICATION_DATE as CHAR(8)),112) end as Application_Date,
--PPOLC.ISSUE_DATE,
case when isdate(PPOLC.ISSUE_DATE)=0  then '01/01/1900' else CONVERT(datetime,CAST(PPOLC.ISSUE_DATE as CHAR(8)),112) end as Issue_Date,
--PPOLC.PAID_TO_DATE,


--CONVERT(datetime,CAST(PPOLC.ACTUAL_BILL_DATE as CHAR(8)),112) as ACTUAL_BILL_DATE,
PPOLC.MODE_PREMIUM as Premium_Amount,
case PPOLC.BILLING_MODE when '1' then 'Monthly' when '3' then 'Quarterly' when '6' then 'Semi-Annual' when '12' then 'Annual' else 'Unknown' end as Premium_Mode,
case when isdate(PPOLC.PAID_TO_DATE)=0 then '01/01/1900'  else CONVERT(datetime,CAST(PPOLC.PAID_TO_DATE as CHAR(8)),112) end as Paid_To_Date,
--substring(cast(PPOLC.ACTUAL_BILL_DATE as char(8)),7,2) as Bill_Day,
Bill_Day = dbo.GTL_get_bill_day(BILL_CODE,POLICY_BILL_DAY,case when isdate(PPOLC.ACTUAL_BILL_DATE)=0  then '00' else   substring(cast(PPOLC.ACTUAL_BILL_DATE as char(8)),7,2) end,case when isdate(PPOLC.ISSUE_DATE)=0  then '00' else   substring(cast(PPOLC.ISSUE_DATE as char(8)),7,2) end),

case PPOLC.BILLING_FORM when 'DIR' then 'Direct Bill' when 'PAC' then 'Bank Draft' when 'LST' then 'List Bill' when 'CRD' then 'Credit Card' else '' end as Method_Of_Payment--,
--PPBEN_POLICY_BENEFITS_TYPES_BA_OR.NUMBER_OF_UNITS * PPBEN_POLICY_BENEFITS_TYPES_BA_OR.VALUE_PER_UNIT as FACE_AMOUNT,
--PPOLC.CONTRACT_CODE,
--PPOLC.CONTRACT_REASON,

--PPOLC.ANNUAL_PREMIUM
,Notes  = dbo.GTL_Policy_Underwriting_Notes(PPOLC.POLICY_NUMBER)
,Case PPOLC.CONTRACT_REASON	
	when 'IC' then 'Incomplete'
	when 'RI' then 'Ready for Issue'
	when 'SM' then 'Submitted'

	else ''
end CONTRACT_REASON_DESC
,PACTG_NSF.RETURN_REASON_CD as RETURN_REASON_CD

from PPOLC 
	join PRELA_RELATIONSHIP_MASTER on PPOLC.COMPANY_CODE + PPOLC.POLICY_NUMBER = PRELA_RELATIONSHIP_MASTER.IDENTIFYING_ALPHA 
	join PAGNT_AGENT_MASTER on PAGNT_AGENT_MASTER.NAME_ID = PRELA_RELATIONSHIP_MASTER.NAME_ID
	left join PPBEN_POLICY_BENEFITS on PPBEN_POLICY_BENEFITS.COMPANY_CODE = PPOLC.COMPANY_CODE and PPBEN_POLICY_BENEFITS.POLICY_NUMBER = PPOLC.POLICY_NUMBER and PPBEN_POLICY_BENEFITS.BENEFIT_SEQ = 1
	left join PPBEN_POLICY_BENEFITS_TYPES_BA_OR on PPBEN_POLICY_BENEFITS.PBEN_ID = PPBEN_POLICY_BENEFITS_TYPES_BA_OR.PBEN_ID
	join PRELA_RELATIONSHIP_MASTER INSURED on PPOLC.COMPANY_CODE + PPOLC.POLICY_NUMBER = INSURED.IDENTIFYING_ALPHA and INSURED.RELATE_CODE = 'IN' and INSURED.BENEFIT_SEQ_NUMBER = 1
	join PNAME on INSURED.NAME_ID = PNAME.NAME_ID
	join PTRNS_SENSITIVE_DATA_TRANSLATE on PNAME.SSN_BTC_HASH = PTRNS_SENSITIVE_DATA_TRANSLATE.HASHED_VALUE and PTRNS_SENSITIVE_DATA_TRANSLATE.FIELD_TYPE = 5
	join PPRDF on PPOLC.PRODUCT_CODE = PPRDF.PRODUCT_ID
        OUTER APPLY (
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
                JOIN PPOLC PPOLC_NSF ON PPOLC_NSF.POLICY_NUMBER = PACTG.POLICY_NUMBER
            WHERE PACTG.COMPANY_CODE = @company_code
                AND PACTG.POLICY_NUMBER = PPOLC.POLICY_NUMBER
                AND PACTG.BENEFIT_SEQ = 01
                AND PACTG.CONTROL_NUMBER = (
                    Select TOP 1 CONTROL_NUMBER From lifepro.dbo.PACTG A1 with(nolock)
                    Where A1.POLICY_NUMBER = PPOLC.POLICY_NUMBER
                    And A1.CREDIT_ACCOUNT = '112600'
                    And Not Exists(Select A2.* From lifepro.dbo.PACTG A2 with(nolock)
                                    Where A2.POLICY_NUMBER = A1.POLICY_NUMBER
                                    And A2.CREDIT_ACCOUNT like '3%'
                                    And (A2.DATE_ADDED > A1.DATE_ADDED Or (A2.DATE_ADDED = A1.DATE_ADDED And A2.TIME_ADDED > A1.TIME_ADDED)))
                    ORDER BY A1.DATE_ADDED DESC, A1.TIME_ADDED DESC, A1.CONTROL_NUMBER DESC
                )
                AND XPRINT_REQUEST.FORM_SUB_TYPE LIKE 'NSF%'
            ORDER BY PACTG.DATE_ADDED DESC, PACTG.TIME_ADDED DESC, PACTG.CONTROL_NUMBER DESC
        ) PACTG_NSF
where	 AGENT_NUMBER in (Select AGENT_NBR collate SQL_Latin1_General_CP1_CI_AS from #hier_final  ) and 
((rtrim(upper(PNAME.INDIVIDUAL_LAST)) = @last_name and convert(char(8),PNAME.DATE_OF_BIRTH,112) = convert(char(8),@dob,112 ) and PPOLC.ZIP = @zipcode)
or 
(rtrim(upper(PNAME.INDIVIDUAL_LAST)) = @last_name and convert(char(8),PNAME.DATE_OF_BIRTH,112) = convert(char(8),@dob,112 ) and right(PTRNS_SENSITIVE_DATA_TRANSLATE.DECRYPTED_VALUE,4) = @ssn))

--((rtrim(PNAME.INDIVIDUAL_LAST) = 'UNDERWOOD'  and PPOLC.ZIP = '37363')
--or 
--(rtrim(PNAME.INDIVIDUAL_LAST) = @last_name and right(PTRNS_SENSITIVE_DATA_TRANSLATE.DECRYPTED_VALUE,4) = @ssn))


union all
select policy_number  collate SQL_Latin1_General_CP1_CI_AS as POLICY_NUMBER,
rtrim(PPRDF.DESCRIPTION)collate SQL_Latin1_General_CP1_CI_AS as DESCRIPTION ,
rtrim(ins_first_name) + ' ' + rtrim(ins_last_name) collate SQL_Latin1_General_CP1_CI_AS as Insured_Name,
'License Review' as Status
,0 as Insured_SSN
,'01/01/1900' as Insured_DOB
,'' collate SQL_Latin1_General_CP1_CI_AS as Insured_Gender
,0 as Insured_Issue_Age
,issue_state collate SQL_Latin1_General_CP1_CI_AS as Issue_State
,app_date as Application_Date
,'01/01/1900' as Issue_Date
,0 as Premium_Amount
,'' collate SQL_Latin1_General_CP1_CI_AS as Premium_Mode
,'01/01/1900' as Paid_To_Date
,'Billing date not set yet' as Bill_Day
,'' collate SQL_Latin1_General_CP1_CI_AS as Method_Of_Payment
,'' collate SQL_Latin1_General_CP1_CI_AS as Notes
,'' collate SQL_Latin1_General_CP1_CI_AS as CONTRACT_REASON_DESC
,'' collate SQL_Latin1_General_CP1_CI_AS as RETURN_REASON_CD


--,app_receivd_date as APP_RECEIVED_DATE
from [vmq-sql2-api.gtldmz.local\sqla].agent_portal.[dbo].[t_agent_error] 
join PPRDF on plan_code = PPRDF.PRODUCT_ID collate SQL_Latin1_General_CP1_CI_AS
--join [vmp-sql2-dmz.gtldmz.local\sqla].ap_lifepro.dbo.PPRDF on plan_code = PPRDF.PRODUCT_ID collate SQL_Latin1_General_CP1_CI_AS
--join [vmp-sql2-dmz.gtldmz.local\sqla].ap_lifepro.dbo.PRELA_RELATIONSHIP_MASTER on left(t_agent_error.agent_code,2) + t_agent_error.POLICY_NUMBER = PRELA_RELATIONSHIP_MASTER.IDENTIFYING_ALPHA collate SQL_Latin1_General_CP1_CI_AS and PRELA_RELATIONSHIP_MASTER.RELATE_CODE = 'SA' collate SQL_Latin1_General_CP1_CI_AS
--join [vmp-sql2-dmz.gtldmz.local\sqla].ap_lifepro.dbo.PAGNT_AGENT_MASTER on PAGNT_AGENT_MASTER.NAME_ID = PRELA_RELATIONSHIP_MASTER.NAME_ID
where agent_code in (Select AGENT_NBR collate SQL_Latin1_General_CP1_CI_AS from #hier_final  )  
and policy_number not in (Select POLICY_NUMBER collate SQL_Latin1_General_CP1_CI_AS from PPOLC)
and 
rtrim(upper(ins_last_name)) = @last_name 


--order by APP_RECEIVED_DATE desc



END




GO


