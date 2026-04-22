BEGIN
DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE( 
host => 'api.cohere.ai',
lower_port => null,
upper_port => null,
ace => xs$ace_type(
privilege_list => xs$name_list('connect', 'resolve'),
principal_name => 'LANGFLOW',
principal_type => xs_acl.ptype_db)
);
END;
/

BEGIN
  DBMS_CLOUD_AI.CREATE_PROFILE(
    profile_name => 'COHERE_PROFILE',
    attributes   => '{
      "provider": "cohere",
      "credential_name": "COHERE_CRED",
      "object_list": [{"owner": "LANGFLOW"}]
    }'
  );
END;
/