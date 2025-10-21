SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




















/******************************************************************************
 * PROCEDURE:	usp_GTL_bot_policy_list
 * DESCRIPTION:	Get list of policies by agent for chatbot
 *             	.
 * CREATE BY:	Richard Black
 * CREATE DATE: 4/24/2024
 * Example:  [usp_GTL_bot_policy_list] '20232C00'
 * REVISIONS:
 *
  ******************************************************************************/
ALTER PROCEDURE [dbo].[usp_GTL_bot_policy_list]
	@AgentNumber char(8)
AS
BEGIN
    DECLARE @company_code CHAR (2)
    DECLARE @agent_nbr CHAR (12)
    DECLARE @market_code CHAR (10)
    DECLARE @agent_level CHAR (2)
    DECLARE @stop_date VARCHAR (8)
    DECLARE @rc INT
    DECLARE @h_id INT
    DECLARE @cur_level INT

	    CREATE TABLE #my_output
    (	[Policy] CHAR (10),
    	[Plan] VARCHAR (50)  ,
    	Insured VARCHAR (50)  ,
    	Status VARCHAR (100)  ,
    	Insured_SSN int,
        Insured_DOB datetime,
        Insured_Gender char(1),
		Insured_Issue_Age int,
		Issue_State char(2),
		Application_Date datetime,
		Issue_Date datetime,
		Premium_Amount decimal (9,2),
		Premium_Mode varchar(20), 
		Paid_To_Date datetime,
		Bill_Day varchar(40) ,
		Method_Of_Payment char(16),
		Notes	varchar(Max),
		CONTRACT_REASON_DESC varchar(30),
		APP_RECEIVED_DATE datetime
		)


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
/*
select top 5 [Policy],[Plan],Insured,Status,APP_RECEIVED_DATE
from 
(
select top 5
--PPOLC.LAST_CHANGE_DATE,
--CONVERT(datetime,CAST(PPOLC.LAST_CHANGE_DATE as CHAR(8)),112) as DATE_UPDATED,
rtrim(PPOLC.POLICY_NUMBER) as Policy,
--PPOLC.PRODUCT_CODE,
rtrim(PPRDF.DESCRIPTION) as [Plan],
rtrim(PNAME.INDIVIDUAL_FIRST) + ' ' + rtrim(PNAME.INDIVIDUAL_LAST) as Insured,
--PPBEN_POLICY_BENEFITS_TYPES_BA_OR.NUMBER_OF_UNITS * PPBEN_POLICY_BENEFITS_TYPES_BA_OR.VALUE_PER_UNIT as Face_Amount,
--PPOLC.CONTRACT_CODE,
case PPOLC.CONTRACT_CODE when 'A' then 'Active'
	when 'T' then 'Terminated'
	when 'P' then 'Pending'
	when 'S' then 'Suspended'
	else 'Unknown' end as Status
	--,AGENT_NUMBER
,PPOLC.APP_RECEIVED_DATE

from PPOLC 
	join PRELA_RELATIONSHIP_MASTER on PPOLC.COMPANY_CODE + PPOLC.POLICY_NUMBER = PRELA_RELATIONSHIP_MASTER.IDENTIFYING_ALPHA and PRELA_RELATIONSHIP_MASTER.RELATE_CODE = 'SA'
	join PAGNT_AGENT_MASTER on PAGNT_AGENT_MASTER.NAME_ID = PRELA_RELATIONSHIP_MASTER.NAME_ID
	join PPBEN_POLICY_BENEFITS on PPBEN_POLICY_BENEFITS.COMPANY_CODE = PPOLC.COMPANY_CODE and PPBEN_POLICY_BENEFITS.POLICY_NUMBER = PPOLC.POLICY_NUMBER and PPBEN_POLICY_BENEFITS.BENEFIT_SEQ = 1
	--join PPBEN_POLICY_BENEFITS_TYPES_BA_OR on PPBEN_POLICY_BENEFITS.PBEN_ID = PPBEN_POLICY_BENEFITS_TYPES_BA_OR.PBEN_ID
	join PRELA_RELATIONSHIP_MASTER INSURED on PPOLC.COMPANY_CODE + PPOLC.POLICY_NUMBER = INSURED.IDENTIFYING_ALPHA and INSURED.RELATE_CODE = 'IN' and INSURED.BENEFIT_SEQ_NUMBER = 1
	join PNAME on INSURED.NAME_ID = PNAME.NAME_ID
	join PPRDF on PPOLC.PRODUCT_CODE = PPRDF.PRODUCT_ID
where  AGENT_NUMBER in (Select AGENT_NBR collate SQL_Latin1_General_CP1_CI_AS from #hier_final  )  
-- order by PPOLC.APP_RECEIVED_DATE desc, PPOLC.POLICY_NUMBER


union ALL

select policy_number  collate SQL_Latin1_General_CP1_CI_AS as Policy,
rtrim(PPRDF.DESCRIPTION)collate SQL_Latin1_General_CP1_CI_AS as [Plan] ,
rtrim(ins_first_name) + ' ' + rtrim(ins_last_name) collate SQL_Latin1_General_CP1_CI_AS as Insured,
'Error' as status
,convert(varchar,app_receivd_date ,112)  collate SQL_Latin1_General_CP1_CI_AS
from [vmq-sql2-api.gtldmz.local\sqla].agent_portal.[dbo].[t_agent_error] 
join PPRDF on plan_code = PPRDF.PRODUCT_ID collate SQL_Latin1_General_CP1_CI_AS
--join [vmq-sql2-dmz.gtldmz.local\sqla].ap_lifepro.dbo.PPRDF on plan_code = PPRDF.PRODUCT_ID collate SQL_Latin1_General_CP1_CI_AS
--join [vmq-sql2-dmz.gtldmz.local\sqla].ap_lifepro.dbo.PRELA_RELATIONSHIP_MASTER on left(t_agent_error.agent_code,2) + t_agent_error.POLICY_NUMBER = PRELA_RELATIONSHIP_MASTER.IDENTIFYING_ALPHA collate SQL_Latin1_General_CP1_CI_AS and PRELA_RELATIONSHIP_MASTER.RELATE_CODE = 'SA' collate SQL_Latin1_General_CP1_CI_AS
--join [vmq-sql2-dmz.gtldmz.local\sqla].ap_lifepro.dbo.PAGNT_AGENT_MASTER on PAGNT_AGENT_MASTER.NAME_ID = PRELA_RELATIONSHIP_MASTER.NAME_ID
where agent_code in (Select AGENT_NBR collate SQL_Latin1_General_CP1_CI_AS from #hier_final  )  
and policy_number not in (Select POLICY_NUMBER collate SQL_Latin1_General_CP1_CI_AS from PPOLC)
--order by Policy
) FullList
order by APP_RECEIVED_DATE desc
*/
/*
select top 5 [Policy],[Plan],Insured,Status,
Insured_SSN,
Insured_DOB,
Insured_Gender,
Insured_Issue_Age,
Issue_State,
Application_Date,
Issue_Date,
Premium_Amount,
Premium_Mode,
Paid_To_Date,
Bill_Day,
Method_Of_Payment,
Notes,
CONTRACT_REASON_DESC,





APP_RECEIVED_DATE
from 
(
*/
insert into #my_output([Policy],[Plan],Insured,Status,Insured_SSN,Insured_DOB,Insured_Gender,Insured_Issue_Age,Issue_State,Application_Date,Issue_Date,Premium_Amount,Premium_Mode,Paid_To_Date,Bill_Day,Method_of_Payment,Notes,CONTRACT_REASON_DESC,APP_RECEIVED_DATE)

select  top 10
PPOLC.POLICY_NUMBER as Policy,
--PPOLC.PRODUCT_CODE,
PPRDF.DESCRIPTION as [Plan],
rtrim(PNAME.INDIVIDUAL_FIRST) + ' ' + rtrim(PNAME.INDIVIDUAL_LAST) as Insured,
case PPOLC.CONTRACT_CODE when 'A' then 'Active'
	when 'T' then 'Terminated'
	when 'P' then 'Pending'
	when 'S' then 'Suspended'
	else 'Unknown' end as Status,
right(PTRNS_SENSITIVE_DATA_TRANSLATE.DECRYPTED_VALUE,4) as Insured_SSN,
--PNAME.DATE_OF_BIRTH,
case when isdate(PNAME.DATE_OF_BIRTH)=0  then '01/01/1900' else  CONVERT(datetime,CAST(PNAME.DATE_OF_BIRTH as CHAR(8)),112) end as Insured_DOB,
PNAME.SEX_CODE as Insured_Gender,
coalesce(PPBEN_POLICY_BENEFITS_TYPES_BA_OR.ISSUE_AGE,0) as Insured_Issue_Age,
coalesce(PPBEN_POLICY_BENEFITS_TYPES_BA_OR.ISSUE_STATE,'') as Issue_State,
case when isdate(PPOLC.APPLICATION_DATE)=0  then '01/01/1900' else CONVERT(datetime,CAST(PPOLC.APPLICATION_DATE as CHAR(8)),112) end as Application_Date,
--PPOLC.ISSUE_DATE as Issue_Date,
--CONVERT(datetime,CAST(PPOLC.ISSUE_DATE as CHAR(8)),112) as Issue_Date,
case when isdate(PPOLC.ISSUE_DATE) =0 then '01/01/1900' else CONVERT(datetime,CAST(PPOLC.ISSUE_DATE as CHAR(8)),112) end as Issue_Date,

--PPOLC.PAID_TO_DATE,


--CONVERT(datetime,CAST(PPOLC.ACTUAL_BILL_DATE as CHAR(8)),112) as ACTUAL_BILL_DATE,
PPOLC.MODE_PREMIUM as Premium_Amount,

case PPOLC.BILLING_MODE when '1' then 'Monthly' when '3' then 'Quarterly' when '6' then 'Semi-Annual' when '12' then 'Annual' else 'Unknown' end as Premium_Mode,
case when isdate(PPOLC.PAID_TO_DATE) =0 then '01/01/1900' else CONVERT(datetime,CAST(PPOLC.PAID_TO_DATE as CHAR(8)),112) end as Paid_To_Date,
--case when isdate(PPOLC.ACTUAL_BILL_DATE)=0  then '0' else   substring(cast(PPOLC.ACTUAL_BILL_DATE as char(8)),7,2) end as Bill_Day,
--'TEST' as Bill_Day,
Bill_Day = dbo.GTL_get_bill_day(BILL_CODE,POLICY_BILL_DAY,case when isdate(PPOLC.ACTUAL_BILL_DATE)=0  then '00' else   substring(cast(PPOLC.ACTUAL_BILL_DATE as char(8)),7,2) end,case when isdate(PPOLC.ISSUE_DATE)=0  then '00' else   substring(cast(PPOLC.ISSUE_DATE as char(8)),7,2) end),






--PPOLC.BILLING_FORM as Method_Of_Payment--,
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
--,PPOLC.APP_RECEIVED_DATE

,case when isdate(PPOLC.APP_RECEIVED_DATE) =0 then '01/01/1900' else CONVERT(datetime,CAST(PPOLC.APP_RECEIVED_DATE as CHAR(8)),112) end as APP_RECEIVED_DATE
from PPOLC 
	join PRELA_RELATIONSHIP_MASTER on PPOLC.COMPANY_CODE + PPOLC.POLICY_NUMBER = PRELA_RELATIONSHIP_MASTER.IDENTIFYING_ALPHA 
	join PAGNT_AGENT_MASTER on PAGNT_AGENT_MASTER.NAME_ID = PRELA_RELATIONSHIP_MASTER.NAME_ID
	left join PPBEN_POLICY_BENEFITS on PPBEN_POLICY_BENEFITS.COMPANY_CODE = PPOLC.COMPANY_CODE and PPBEN_POLICY_BENEFITS.POLICY_NUMBER = PPOLC.POLICY_NUMBER and PPBEN_POLICY_BENEFITS.BENEFIT_SEQ = 1
	left join PPBEN_POLICY_BENEFITS_TYPES_BA_OR on PPBEN_POLICY_BENEFITS.PBEN_ID = PPBEN_POLICY_BENEFITS_TYPES_BA_OR.PBEN_ID
	join PRELA_RELATIONSHIP_MASTER INSURED on PPOLC.COMPANY_CODE + PPOLC.POLICY_NUMBER = INSURED.IDENTIFYING_ALPHA and INSURED.RELATE_CODE = 'IN' and INSURED.BENEFIT_SEQ_NUMBER = 1
	join PNAME on INSURED.NAME_ID = PNAME.NAME_ID
	join PTRNS_SENSITIVE_DATA_TRANSLATE on PNAME.SSN_BTC_HASH = PTRNS_SENSITIVE_DATA_TRANSLATE.HASHED_VALUE and PTRNS_SENSITIVE_DATA_TRANSLATE.FIELD_TYPE = 5
	join PPRDF on PPOLC.PRODUCT_CODE = PPRDF.PRODUCT_ID
where AGENT_NUMBER in (Select AGENT_NBR collate SQL_Latin1_General_CP1_CI_AS from #hier_final) 
and DateDiff("MONTH", CONVERT(datetime, convert(char(8), case when isdate(APP_RECEIVED_DATE) = 0 then 19010101 else APP_RECEIVED_DATE end)),getdate()) <=3
order by APP_RECEIVED_DATE desc

--union ALL
insert into #my_output([Policy],[Plan],Insured,Status,Insured_SSN,Insured_DOB,Insured_Gender,Insured_Issue_Age,Issue_State,Application_Date,Issue_Date,Premium_Amount,Premium_Mode,Paid_To_Date,Bill_Day,Method_of_Payment,Notes,CONTRACT_REASON_DESC,APP_RECEIVED_DATE)

select policy_number  collate SQL_Latin1_General_CP1_CI_AS as Policy,
rtrim(PPRDF.DESCRIPTION)collate SQL_Latin1_General_CP1_CI_AS as [Plan] ,
rtrim(ins_first_name) + ' ' + rtrim(ins_last_name) collate SQL_Latin1_General_CP1_CI_AS as Insured,
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


,app_receivd_date as APP_RECEIVED_DATE
from [vmq-sql2-api.gtldmz.local\sqla].agent_portal.[dbo].[t_agent_error] 
join PPRDF on plan_code = PPRDF.PRODUCT_ID collate SQL_Latin1_General_CP1_CI_AS
--join [vmq-sql2-dmz.gtldmz.local\sqla].ap_lifepro.dbo.PPRDF on plan_code = PPRDF.PRODUCT_ID collate SQL_Latin1_General_CP1_CI_AS
--join [vmq-sql2-dmz.gtldmz.local\sqla].ap_lifepro.dbo.PRELA_RELATIONSHIP_MASTER on left(t_agent_error.agent_code,2) + t_agent_error.POLICY_NUMBER = PRELA_RELATIONSHIP_MASTER.IDENTIFYING_ALPHA collate SQL_Latin1_General_CP1_CI_AS and PRELA_RELATIONSHIP_MASTER.RELATE_CODE = 'SA' collate SQL_Latin1_General_CP1_CI_AS
--join [vmq-sql2-dmz.gtldmz.local\sqla].ap_lifepro.dbo.PAGNT_AGENT_MASTER on PAGNT_AGENT_MASTER.NAME_ID = PRELA_RELATIONSHIP_MASTER.NAME_ID
where agent_code in (Select AGENT_NBR collate SQL_Latin1_General_CP1_CI_AS from #hier_final  )  
and policy_number not in (Select POLICY_NUMBER collate SQL_Latin1_General_CP1_CI_AS from PPOLC)
and DateDiff("MONTH", CONVERT(datetime, convert(char(8), case when isdate(app_receivd_date) = 0 then 19010101 else app_receivd_date end)),getdate()) <=3
order by APP_RECEIVED_DATE desc

--) FullList
--order by APP_RECEIVED_DATE desc



select top 5 [Policy],[Plan],Insured,Status,APP_RECEIVED_DATE,Insured_SSN,Insured_DOB,Insured_Gender,Insured_Issue_Age,Issue_State,Application_Date,Issue_Date,Premium_Amount,Premium_Mode,Paid_To_Date,Bill_Day,Method_of_Payment,Notes,CONTRACT_REASON_DESC
from #my_output 
--where APP_RECEIVED_DATE >= dateadd(M,-3,getdate())
group by [Policy],[Plan],Insured,Status,APP_RECEIVED_DATE,Insured_SSN,Insured_DOB,Insured_Gender,Insured_Issue_Age,Issue_State,Application_Date,Issue_Date,Premium_Amount,Premium_Mode,Paid_To_Date,Bill_Day,Method_of_Payment,Notes,CONTRACT_REASON_DESC
order by APP_RECEIVED_DATE desc


END
GO
