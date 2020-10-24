CREATE DATABASE CAR_SELLER
GO

USE CAR_SELLER
GO

CREATE TABLE USER_ACCOUNT(
	userid INT IDENTITY(0,1) PRIMARY KEY,
	username VARCHAR(20) NOT NULL,
	email VARCHAR(50) NOT NULL,
	password VARCHAR(100) NOT NULL
)
GO

CREATE TABLE USER_INFOMATION(
	userid INT PRIMARY KEY,
	firstname NVARCHAR(50) NOT NULL,
	lastname NVARCHAR(50) NOT NULL,
	phone VARCHAR(10) NOT NULL,
	email VARCHAR(50) NOT NULL,
	address NVARCHAR (100) NOT NULL,
	user_image VARCHAR(100),
	CONSTRAINT FK_ACC_INFO FOREIGN KEY (userid) REFERENCES USER_ACCOUNT(userid)
)
GO

CREATE TABLE CATOGORY(
	cat_id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	cat_name NVARCHAR(100),
	cat_desciption NVARCHAR(100)
)
GO

ALTER TABLE PRODUCT ADD used BIT, run_mile FLOAT

CREATE TABLE PRODUCT(
	product_id INT PRIMARY KEY IDENTITY(0,1),
	product_name NVARCHAR(50) NOT NULL,
	has_event BIT,
	cat_id INT,
	storage_amount INT NOT NULL,
	product_image VARCHAR(50),
	price MONEY NOT NULL,
	CONSTRAINT FK_PRODUCT_CATOGORY FOREIGN KEY (cat_id) REFERENCES CATOGORY(cat_id)
)
GO

CREATE TABLE PRODUCT_SPEC(
	product_id INT PRIMARY KEY,
	size_height FLOAT NOT NULL, --Chieu cao
	size_long FLOAT NOT NULL, --Chieu dao
	size_wide FLOAT NOT NULL, --Chieu rong
	size_long_wheelbase FLOAT NOT NULL, --Chieu dai co so
	size_front_wide_wheelbase FLOAT NOT NULL, --Chieu rong co so truoc
	size_back_wide_wheelbase FLOAT NOT NULL, --Chieu rong co so sau
	minimum_turning_radius FLOAT NOT NULL, --Ban kinh quay vong nho nhat
	ground_clearance FLOAT NOT NULL, --Khoang sang gam xe
	weight_non_load FLOAT NOT NULL, --Trong luong khong tai
	number_capacity INT NOT NULL, --So cho ngoi
	engineen_type NVARCHAR(50) NOT NULL, --Loai dong co
	cylinder_capacity FLOAT NOT NULL, --Dung tich xi lanh
	maximum_power VARCHAR(20) NOT NULL, --Cong suat cuc dai
	maximum_torque VARCHAR(20) NOT NULL, --Momen xoan cuc dai
	gas_capacity FLOAT NOT NULL, --Dung tich thung nhien lieu
	gear_box NVARCHAR(100) NOT NULL, --Hop so
	actuate NVARCHAR(50) NOT NULL,
	power_steering NVARCHAR(50) NOT NULL,
	front_suspension NVARCHAR(50) NOT NULL,
	back_suspension NVARCHAR(50) NOT NULL,
	front_back_tyre NVARCHAR(50) NOT NULL,
	front_back_break NVARCHAR(50) NOT NULL,
	gas_consumption_avg FLOAT NOT NULL,
	CONSTRAINT FK_SPEC_PRODUCT FOREIGN KEY (product_id) REFERENCES PRODUCT(product_id)
)
GO

CREATE TABLE PRODUCT_OUTFIT(
	product_id INT PRIMARY KEY,
	number_of_color INT NOT NULL,
	day_light BIT,
	light_sensor BIT,
	fog_light BIT,
	washing_light BIT,
	wheel_size FLOAT,
	sit_material NVARCHAR(50),
	camera INT,
	CONSTRAINT FK_OUTFIT_PRODUCT FOREIGN KEY (product_id) REFERENCES PRODUCT(product_id)
)
GO

CREATE TABLE FAVORITE(
	fav_id INT IDENTITY(1,1) PRIMARY KEY,
	userid INT,
	product_id INT,
	CONSTRAINT FK_FAVORITE_PRODUCT FOREIGN KEY (product_id) REFERENCES PRODUCT(product_id),
	CONSTRAINT FK_FAVORITE_INFO FOREIGN KEY (userid) REFERENCES USER_INFOMATION(userid)
) 
GO

CREATE TABLE BILL(
	bill_id INT IDENTITY(1,1) PRIMARY KEY,
	buy_date DATETIME,
	product_id INT,
	userid INT,
	amount INT,
	price MONEY,
	total MONEY,
	CONSTRAINT FK_BILL_PRODUCT FOREIGN KEY (product_id) REFERENCES PRODUCT(product_id),
	CONSTRAINT FK_BILL_INFO FOREIGN KEY (userid) REFERENCES USER_INFOMATION(userid)
)
GO

CREATE TABLE HISTORY(
	history_id INT IDENTITY(1,1) PRIMARY KEY,
	bill_id INT,
	CONSTRAINT FK_BILL_HISTORY FOREIGN KEY (bill_id) REFERENCES BILL(bill_id)
)
GO

CREATE TABLE COMMENT(
	comment_id INT IDENTITY(1,1) PRIMARY KEY,
	product_id INT,
	userid INT,
	comment_date DATETIME,
	comment_content NVARCHAR(200),
	comment_like INT,
	reported INT,
	CONSTRAINT FK_COMMENT_PRODUCT FOREIGN KEY (product_id) REFERENCES PRODUCT(product_id),
	CONSTRAINT FK_COMMENT_INFO FOREIGN KEY (userid) REFERENCES USER_INFOMATION(userid)
)
GO

CREATE TABLE RATE(
	rate_id INT IDENTITY(1,1) PRIMARY KEY,
	product_id INT,
	userid INT,
	rate_content NVARCHAR(150),
	rate_image_list NVARCHAR(1000),
	rate_weight FLOAT,
	CONSTRAINT FK_RATE_PRODUCT FOREIGN KEY (product_id) REFERENCES PRODUCT(product_id),
	CONSTRAINT FK_RATE_INFO FOREIGN KEY (userid) REFERENCES USER_INFOMATION(userid)
)
GO

CREATE TABLE ADSIVERMENT(
	ads_id INT IDENTITY(1,1) PRIMARY KEY,
	ads_image VARCHAR(100),
	location INT,
	begin_date DATETIME,
	end_date DATETIME,
	detail_page VARCHAR(100)
)
GO

CREATE TABLE EVENT(
	event_id INT IDENTITY(1,1) PRIMARY KEY,
	product_id INT,
	disount FLOAT,
	begin_date DATETIME,
	end_date DATETIME,
	CONSTRAINT FK_EVENT_PRODUCT FOREIGN KEY (product_id) REFERENCES PRODUCT(product_id)
)
GO

ALTER TABLE USER_ACCOUNT ADD role VARCHAR(5)


INSERT INTO USER_ACCOUNT
VALUES ('xiabui', 'buivanxia10@gmail.com', '$2y$10$ANDSr2CHV9c4z7wC4OPRn.3U.OrNrMgde/8PnzKR4bF0Vx7HzBzAO', 'admin')
GO



CREATE PROC proc_login (@username_email VARCHAR(50))
AS
	BEGIN
		DECLARE @password_hash VARCHAR(100);
		SELECT @password_hash = password FROM USER_ACCOUNT WHERE username = @username_email OR email = @username_email;
	END;
GO

CREATE PROC proc_get_car_new
	@PageIndex int = 1,
	@PageSize int = 9,
	@RecordCount int out
as
begin
	SET NOCOUNT ON;
 
    SELECT  (ROW_NUMBER() OVER(Order By product_id)) AS RowNumber,
            product_id,
			product_name,
			product_image,
			storage_amount,
			price
    INTO #Results  
    FROM PRODUCT
	WHERE used = 'False';
 
    SELECT @RecordCount = Count(*) FROM #Results
 
    SELECT * FROM #Results WHERE
    ROWNUMBER BETWEEN  (@PageIndex-1)*@PageSize + 1 AND (((@PageIndex-1)*@PageSize + 1)+@PageSize)-1 OR @PageIndex = -1
     
 
    DROP TABLE #Results
END
GO


CREATE PROC proc_add_product
	@product_name NVARCHAR(50),
	@has_event BIT,
	@cat_id INT,
	@storage_amount INT,
	@product_image VARCHAR(50),
	@price MONEY,
	@used BIT
AS
	BEGIN
		INSERT INTO PRODUCT(product_name, has_event, cat_id, storage_amount, product_image, price, used)
		VALUES (@product_name, @has_event, @cat_id, @storage_amount, @product_image, @price, @used)
	END
GO

ALTER TABLE PRODUCT ADD coutry_made NVARCHAR(20)
GO

CREATE PROC proc_get_product_spec_with_id(@product_id INT)
AS
	BEGIN
		SELECT P.product_image, P.price, P.product_name, P.coutry_made, P.used, C.cat_name, P.run_mile, PS.gas_capacity, PS.number_capacity, PS.engineen_type 
		FROM PRODUCT P, PRODUCT_SPEC PS, CATOGORY C
		WHERE P.product_id = PS.product_id AND P.cat_id = C.cat_id AND P.product_id = @product_id
	END
GO

proc_get_product_spec_with_id 0
