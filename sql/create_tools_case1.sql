-- FUNCTION EMBEDD AND INGEST CHUNK
create or replace FUNCTION LANGFLOW.ingest_chunk (
  p_doc_id     IN VARCHAR2,
  p_text       IN CLOB,
  p_meta_json  IN CLOB
) RETURN CLOB AS
  v_emb VECTOR;
BEGIN
	SELECT DBMS_VECTOR.UTL_TO_EMBEDDING(
	  p_text,
	  JSON('{
	  "provider"       : "cohere",
	  "credential_name": "COHERE_CRED",
	  "url"            : "https://api.cohere.ai/v1/embed",
	  "model"          : "embed-v4.0"
	}')
	) into v_emb FROM DUAL;

  INSERT INTO rag_chunks (doc_id, chunk_id, chunk_text, embedding, meta_json)
  VALUES (p_doc_id, CHUNK_SEQ.NEXTVAL , p_text, v_emb, p_meta_json);
  commit;  
  RETURN '{"status":"ok"}';
END;
/


-- TOOL EMBEDD AND INGEST CHUNK
BEGIN
  DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
    tool_name  => 'INGEST_CHUNK',
    attributes => '{
      "instruction": "Ingest a chunk: generate embedding and persist.",
      "function": "INGEST_CHUNK",
      "tool_inputs": [
        {"name":"doc_id","description":"Document id"},
        {"name":"text","description":"Chunk text"},
        {"name":"meta_json","description":"Metadata JSON"}
      ]
    }'
  );
END;
/


-- FUNCTION VECTOR SEARCH
create or replace FUNCTION LANGFLOW.search_topk (
  p_query_text IN CLOB,
  p_k          IN NUMBER
) RETURN CLOB AS
  v_qemb VECTOR;
  v_json CLOB;
BEGIN
  -- v_qemb := VECTOR_EMBEDDING(p_query_text /* + params do modelo/provider */);
  SELECT DBMS_VECTOR.UTL_TO_EMBEDDING(
	  p_query_text,
	  JSON('{
	  "provider"       : "cohere",
	  "credential_name": "COHERE_CRED",
	  "url"            : "https://api.cohere.ai/v1/embed",
	  "model"          : "embed-v4.0"
	}')
	) into v_qemb FROM DUAL;

  SELECT NVL(
           JSON_ARRAYAGG(
             JSON_OBJECT(
               'doc_id'     VALUE doc_id,
               'chunk_id'   VALUE chunk_id,
               'chunk_text' VALUE chunk_text,
               'meta'       VALUE meta_json
             ) RETURNING CLOB
           ),
           '{result:[]}'
         )
  INTO v_json
  FROM (
    SELECT doc_id, chunk_id, chunk_text, meta_json
    FROM rag_chunks
    ORDER BY VECTOR_DISTANCE(embedding, v_qemb) -- ou operador equivalente no seu release
    FETCH FIRST p_k ROWS ONLY
  );

  RETURN v_json;
END;
/

-- TOOL VECTOR SEARCH
BEGIN
  DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
    tool_name  => 'SEARCH_TOPK',
    attributes => '{
      "instruction": "Vector search top-k for RAG retrieval.",
      "function": "SEARCH_TOPK",
      "tool_inputs": [
        {"name":"query_text","description":"User question or query"},
        {"name":"k","description":"Top K"}
      ]
    }'
  );
END;
/
