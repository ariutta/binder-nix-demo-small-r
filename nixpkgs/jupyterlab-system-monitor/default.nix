{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, jupyterlab
, jupyter-resource-usage
, jupyterlab-topbar
}:

buildPythonPackage rec {
  pname = "jupyterlab-system-monitor";
  version = "0.8.0";
  name = "${pname}-${version}";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1pwl1mny6rvbf7sri8p9hpxdr6znsnlz2w75hl63113cw8z3vl7q";
  };

  doCheck = true;
  buildInputs = [ setuptools ];
  propagatedBuildInputs = [ jupyterlab jupyter-resource-usage jupyterlab-topbar ];

  meta = with lib; {
    description = "JupyterLab extension to display system information.";
    homepage = "https://pypi.org/project/jupyterlab-system-monitor/";
    license = licenses.bsd3;
    maintainers = [];
  };
}
