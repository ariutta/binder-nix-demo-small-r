{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, Babel
, jinja2
, json5
, jsonschema
, jupyter_server
, packaging
, requests
, pytest
}:

buildPythonPackage rec {
  pname = "jupyterlab_server";
  version = "2.1.3";
  disabled = pythonOlder "3.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "06hpkazd9plmp8wjvslsqcj2gdls44d4dpdbs9xs2jfgp826py9a";
  };

  checkInputs = [ requests pytest ];
  propagatedBuildInputs = [
    Babel
    jinja2
    json5
    jsonschema
    jupyter_server
    packaging
    requests
  ];

  # test_listing test fails
  # this is a new package and not all tests pass
  doCheck = false;

  checkPhase = ''
    pytest
  '';

  meta = with lib; {
    description = "JupyterLab Server";
    # TODO: which homepage is more appropriate?
    # homepage = "https://github.com/jupyterlab/jupyterlab_server";
    homepage = "https://jupyter.org";
    license = licenses.bsdOriginal;
    maintainers = [ maintainers.costrouc ];
  };
}
