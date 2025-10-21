-- Test script for usp_GTL_bot_policy_detail_by_name_nsf
-- Test case with provided parameters

USE [lifepro]
GO

-- Declare test parameters
DECLARE @AgentNumber CHAR(8) = '202A2T11'
DECLARE @last_name VARCHAR(40) = 'White'
DECLARE @dob DATETIME = '1957-11-29'
DECLARE @zipcode CHAR(5) = ''
DECLARE @ssn CHAR(4) = '6354'

-- Display test parameters
PRINT 'Test Parameters:'
PRINT 'Agent Number: ' + @AgentNumber
PRINT 'Last Name: ' + @last_name
PRINT 'Date of Birth: ' + CONVERT(VARCHAR(10), @dob, 120)
PRINT 'Zip Code: ' + ISNULL(@zipcode, 'NULL')
PRINT 'SSN (last 4): ' + @ssn
PRINT 'Company Code (derived): ' + LEFT(@AgentNumber, 2)
PRINT ''
PRINT 'Executing stored procedure...'
PRINT ''

-- Execute the stored procedure
EXEC [dbo].[usp_GTL_bot_policy_detail_by_name] 
    @AgentNumber = @AgentNumber,
    @last_name = @last_name,
    @dob = @dob,
    @zipcode = @zipcode,
    @ssn = @ssn

-- Display completion message
PRINT ''
PRINT 'Test execution completed.'
