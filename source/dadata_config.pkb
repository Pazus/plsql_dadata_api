CREATE OR REPLACE PACKAGE BODY dadata_config IS

  FUNCTION get_authorization_token RETURN VARCHAR2 IS
  BEGIN
    RETURN '59b1609de246dc4e4f0c7c5eac29948c1924c1e7';
  END;

  FUNCTION get_x_secret RETURN VARCHAR2 IS
  BEGIN
    RETURN '3732eb45118548880d004abd05782e5570fdcb47';
  END;

END dadata_config;
/
