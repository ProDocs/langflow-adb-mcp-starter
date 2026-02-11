BEGIN
  DBMS_CLOUD.CREATE_CREDENTIAL(
    credential_name => 'COHERE_CRED',
    username        => 'COHERE',
    password        => '<YOUR_COHERE_API_KEY>'
  );
END;
/