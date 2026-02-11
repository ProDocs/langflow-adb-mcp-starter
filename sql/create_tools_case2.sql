-- FUNCTION NL2SQL via Select AI
create or replace FUNCTION LANGFLOW.NL2SQL (
  p_pergunta IN CLOB
) RETURN CLOB
IS
  v_resp CLOB;
BEGIN
  v_resp := DBMS_CLOUD_AI.GENERATE(
              prompt       => p_pergunta,
              action       => 'runsql',
              profile_name => 'COHERE_PROFILE'
            );

  -- Envolve o array retornado em {"resultados": ...}
  RETURN '{"resultados":' || v_resp || '}';

EXCEPTION
  WHEN OTHERS THEN
    RETURN '{"erro":"' || REPLACE(SQLERRM, '"', '\"') || '"}';
END;
/


-- TOOL NL2SQL via Select AI
BEGIN
  DBMS_CLOUD_AI_AGENT.CREATE_TOOL(
    tool_name  => 'TOOL_NL2SQL',
    attributes => '{
      "instruction": "Realiza consultas SQL na base de dados local a partir de perguntas feitas em linguagem natural.",
      "function": "NL2SQL",
      "tool_inputs": [
        {"name":"pergunta","description":"User question or query"}
      ]
    }'
  );
END;
/