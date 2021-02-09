{ lib
, buildPythonPackage
, fetchPypi
, jupyterlab
}:

buildPythonPackage rec {
  pname = "jupyterlab_hide_code";
  version = "3.0.1";
  name = "${pname}-${version}";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0bh5l723mpb795xms4bg47sbidf687h7plabyy7hq29df0f6svc3";
  };

  doCheck = true;
  buildInputs = [];
  propagatedBuildInputs = [ jupyterlab ];

  meta = with lib; {
    description = "A JupyterLab extension to run and hide the codecells.";
    homepage = "https://pypi.org/project/jupyterlab-hide-code/";
    license = licenses.bsd3;
    maintainers = [];
  };
}
