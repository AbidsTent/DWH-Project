-- Stored Procedure: Load Bronze Layer
-- Here we can bulk load each table of the bronze layer with a single procedure from original files
-- To execute the procedure: EXEC bronze.load_bronze; 

create or alter procedure bronze.load_bronze as 

BEGIN
	Declare @start_time DATETIME, @end_time DATETIMe, @bronze_start datetime,@bronze_end datetime;
	BEGIN TRY
	set @bronze_start = getdate();
	print '=========================== Loading Bronze Layer ==========================='

	-- Load data below
	print 'Loading CRM Tables...'

	SET @start_time = GETDATE();
	print 'Truncating table: bronze.crm_cust_info.'
	truncate table bronze.crm_cust_info;
	print 'Inserting Table: bronze.crm_cust_info.'
	bulk insert bronze.crm_cust_info 
	from 'C:\DW_proj\dwh_proj\01_datasets\source_crm\cust_info.csv'
	with (
		firstrow = 2,
		fieldterminator = ',',
		tablock
	);
	SET @end_time = GETDATE();
	print '>> Time spent: '+ CAST(datediff(second, @start_time, @end_time) as nvarchar) + 'seconds';

	SET @start_time= GETDATE();
	print 'Truncating table: bronze.crm_prd_info.'
	truncate table bronze.crm_prd_info;

	print 'Inserting Table: bronze.crm_prd_info.'

	bulk insert bronze.crm_prd_info
	from 'C:\DW_proj\dwh_proj\01_datasets\source_crm\prd_info.csv'
	with (
		firstrow = 2,
		fieldterminator = ',',
		tablock
	);
	SET @end_time= GETDATE();
	print '>> Loading time: '+CAST(datediff (second, @start_time, @end_time)as nvarchar)+' seconds'


	SET @start_time= getdate();
	print 'Truncating table: bronze.crm_sales_details.'

	truncate table bronze.crm_sales_details;
	print 'Inserting Table: bronze.crm_sales_details.'

	bulk insert bronze.crm_sales_details
	from 'C:\DW_proj\dwh_proj\01_datasets\source_crm\sales_details.csv'
	with(
		firstrow = 2,
		fieldterminator= ',',
		tablock
	);
	Set @end_time = getdate();
	print '>> Loading time: '+ cast(datediff(second, @start_time, @end_time) as nvarchar)+' seconds'

	print 'Loading ERP tables...'

	SET @start_time= getdate();
	print 'Truncating table: bronze.erp_cust_az12.'
	truncate table bronze.erp_cust_az12;
	print 'Inserting Table: bronze.erp_cust_az12.'

	bulk insert bronze.erp_cust_az12
	from 'C:\DW_proj\dwh_proj\01_datasets\source_erp\CUST_AZ12.csv'
	with (
		firstrow= 2,
		fieldterminator=',',
		tablock
	);
	Set @end_time = getdate();
	print '>> Loading time: '+ cast(datediff(second, @start_time, @end_time) as nvarchar)+' seconds'

	SET @start_time= getdate();
	print 'Truncating table: bronze.erp_loc_a101.'

	truncate table bronze.erp_loc_a101;
	print 'Inserting Table: bronze.erp_loc_a101.'

	bulk insert bronze.erp_loc_a101
	from 'C:\DW_proj\dwh_proj\01_datasets\source_erp\LOC_A101.csv'
	with (
		firstrow= 2,
		fieldterminator = ',',
		tablock
	);
	Set @end_time = getdate();
	print '>> Loading time: '+ cast(datediff(second, @start_time, @end_time) as nvarchar)+' seconds'

	SET @start_time= getdate();
	print 'Truncating table: bronze.erp_px_cat_g1v2.'

	truncate table bronze.erp_px_cat_g1v2;
	print 'Inserting Table: bronze.erp_px_cat_g1v2.'

	bulk insert bronze.erp_px_cat_g1v2
	from 'C:\DW_proj\dwh_proj\01_datasets\source_erp\PX_CAT_G1V2.csv'
	with (
		firstrow = 2,
		fieldterminator = ',',
		tablock
	);
	Set @end_time = getdate();
	print '>> Loading time: '+ cast(datediff(second, @start_time, @end_time) as nvarchar)+' seconds'
	set @bronze_end = getdate();
	print '-----------------------------------------------------'
	print 'Bronze layer compiled'
	print '>>Loading Duration: '+cast(datediff(second,@bronze_start, @bronze_end) as nvarchar)+' seconds.'
	print '-----------------------------------------------------'
	END TRY
	BEGIN CATCH
		PRINT '============================'
		print 'Error found while loading BRONZE Layer'
		print 'Error Message: ' + error_message();
		print 'Error Message: ' + cast(Error_number() as nvarchar);
		print 'Error Message: ' + cast(Error_State() as nvarchar);
		PRINT '============================'
	END CATCH
END;
