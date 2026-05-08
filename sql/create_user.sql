-- USER SQL
CREATE USER LANGFLOW IDENTIFIED BY "Super#STRONG#1234";

-- ADD ROLES
GRANT CONNECT TO LANGFLOW;
GRANT DB_DEVELOPER_ROLE TO LANGFLOW;
GRANT RESOURCE TO LANGFLOW;
GRANT EXECUTE ON DBMS_CLOUD TO LANGFLOW;
GRANT EXECUTE ON DBMS_CLOUD_AI TO LANGFLOW;
GRANT EXECUTE ON DBMS_CLOUD_AI_AGENT TO LANGFLOW;
GRANT EXECUTE ON DBMS_NETWORK_ACL_ADMIN TO LANGFLOW;    
ALTER USER LANGFLOW DEFAULT ROLE CONNECT,RESOURCE;

-- REST ENABLE
BEGIN
    ORDS_ADMIN.ENABLE_SCHEMA(
        p_enabled => TRUE,
        p_schema => 'LANGFLOW',
        p_url_mapping_type => 'BASE_PATH',
        p_url_mapping_pattern => 'langflow',
        p_auto_rest_auth=> TRUE
    );
    -- ENABLE DATA SHARING
    C##ADP$SERVICE.DBMS_SHARE.ENABLE_SCHEMA(
            SCHEMA_NAME => 'LANGFLOW',
            ENABLED => TRUE
    );
    commit;
END;
/

-- QUOTA
ALTER USER LANGFLOW QUOTA UNLIMITED ON DATA;



BEGIN
  DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
    host => '*',
    ace => xs$ace_type(privilege_list => xs$name_list('connect'),
                       principal_name => 'LANGFLOW',
                       principal_type => xs_acl.ptype_db));
END;
/