CREATE OR REPLACE PACKAGE dadata_config IS

  FUNCTION get_authorization_token RETURN VARCHAR2;
  FUNCTION get_x_secret RETURN VARCHAR2;

END dadata_config;
/
