{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, python3Packages
, jupyterlab
}:

buildPythonPackage rec {
  pname = "jupyter-resource-usage";
  version = "0.5.1";
  name = "${pname}-${version}";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0jhky6lffzj5s4cf5c61adz1s0hbx5l4v9fnyx5i1jdvh6h3kpks";
  };

  doCheck = false;
  buildInputs = [ setuptools ];
  propagatedBuildInputs = [ jupyterlab python3Packages.prometheus_client python3Packages.notebook python3Packages.psutil ];

  meta = with lib; {
    description = "Simple Jupyter extension to show how much resources (RAM) your notebook is using.";
    homepage = "https://pypi.org/project/jupyter-resource-usage/";
    license = licenses.bsd3;
    maintainers = [];
  };
}
