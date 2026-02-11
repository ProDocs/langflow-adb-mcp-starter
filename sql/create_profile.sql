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