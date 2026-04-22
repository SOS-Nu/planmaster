note trường đang thiếu
o.U_StandardList trong oitm

2. Nên chia mấy store?

👉 Chuẩn nhất: 3 store

✅ (1) Store lấy danh sách item (Header)
sp_DMS_GetItems
✅ (2) Store lấy tồn kho (Details)
sp_DMS_GetItemStocks
✅ (3) Store master (gộp output JSON / paging / filter)
sp_DMS_SyncItems

<?xml version="1.0" encoding="utf-8" ?>
<root>
	<SERVER>172.20.146.57:30015</SERVER>
	<SERVERDI>NDB@172.20.146.57:30013</SERVERDI>
	<LICENSESERVER>172.20.146.57:40000</LICENSESERVER>
	<SERVICELAYER>https://172.20.146.57:50000/b1s/v1</SERVICELAYER>
	<SERVERTYPE>HANADB</SERVERTYPE>
	<DBNAME>NTN2</DBNAME>
	<DBUSER>B1SYSTEM</DBUSER>
	<DBPASS>Bts#@2025</DBPASS>
	<COMPANYUSER>dev</COMPANYUSER>
	<COMPANYPASS>1234</COMPANYPASS>
	<PrefixCardCode>BO</PrefixCardCode>
  <UserID>DMSapi</UserID>
  <Password>1234</Password>
	<WhiteListedIPAddresses>*</WhiteListedIPAddresses>
	<ENV>GLC - DMS</ENV>
	<APILOG_DATA_DAYS>3</APILOG_DATA_DAYS>
	<SECOND_LIMIT_REQUEST>0</SECOND_LIMIT_REQUEST>
	<jselectcmdtimeout>90</jselectcmdtimeout>
	<jexeccmdtimeout>90</jexeccmdtimeout>

    <enviroment>test</enviroment>
    <menu>dms</menu>
    <!--pro-Production, test-Testing, dev-Development (default)-->

</root>
