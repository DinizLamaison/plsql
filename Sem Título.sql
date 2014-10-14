create or replace PACKAGE BODY        PKG_EVENTOS AS 
  FUNCTION getDescricao(plc VARCHAR2, cod NUMBER, er CHAR, acess CHAR) RETURN VARCHAR2
  IS 
    retorno VARCHAR2(200):=null;
  BEGIN
      SELECT descricao INTO retorno FROM (
          SELECT descricao, codigo, enviada_recebida, acessorio FROM monitoramento.evento_modelo WHERE modelo = (SELECT NVL(modelo_aparelho,6) FROM monitoramento.veiculo WHERE placa = plc)
          UNION ALL 
          SELECT descricao, codigo, enviada_recebida, acessorio FROM monitoramento.evento_veiculo WHERE placa = plc
      ) 
      WHERE codigo = cod AND enviada_recebida = er AND acessorio = acess AND ROWNUM = 1; 
      
      RETURN retorno;
  END getDescricao;
  
  FUNCTION getDescricaoDefault(cod NUMBER, er CHAR, acess CHAR) RETURN VARCHAR2
  IS 
    retorno VARCHAR2(200):=null;
  BEGIN
      SELECT descricao INTO retorno FROM (
          SELECT descricao, codigo, enviada_recebida, acessorio FROM monitoramento.evento_modelo
          UNION ALL 
          SELECT descricao, codigo, enviada_recebida, acessorio FROM monitoramento.evento_acessorio
      ) 
      WHERE codigo = cod AND enviada_recebida = er AND acessorio = acess AND ROWNUM = 1; 
      
      RETURN retorno;
  END getDescricaoDefault;
  
  
  FUNCTION getParametroDescricao(cod NUMBER, param VARCHAR, er CHAR, acess CHAR, div CHAR) RETURN VARCHAR2
  IS 
    i NUMBER(4):=1;
    retorno VARCHAR2(500):='';
  BEGIN
       IF((cod = 900 OR cod = 901 OR cod = 902) AND er = 'R') THEN
            BEGIN
                SELECT descricao INTO retorno FROM monitoramento.pontos_referencia WHERE id_referencia = param;
                retorno := '<b>Pontos de Refer?ncia:</b>: '||retorno;
            EXCEPTION WHEN NO_DATA_FOUND THEN
                retorno := NULL;
            END;
       ELSE
            DECLARE CURSOR parametros Is
                SELECT tamanho, descricao FROM monitoramento.parametro_formatacao 
                WHERE codigo = cod AND acessorio = acess AND enviada_recebida = er
                ORDER BY sequencia;
            BEGIN
              FOR parametro IN parametros LOOP
                BEGIN
                  retorno := retorno||'<b>'||parametro.descricao||':</b> '||SUBSTR(param,i,parametro.tamanho)||div;
                  i := i+parametro.tamanho;
                END;
              END LOOP;
            END;
            retorno := SUBSTR(retorno,0,LENGTH(retorno)-LENGTH(div));
       END IF;
       
      RETURN retorno;
  END getParametroDescricao;
END;