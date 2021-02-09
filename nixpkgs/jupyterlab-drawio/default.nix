{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, jupyterlab
}:

buildPythonPackage rec {
  pname = "jupyterlab-drawio";
  version = "0.8.0";
  name = "${pname}-${version}";

  src = fetchPypi {
    inherit pname version;
    sha256 = "02c056nlvnap8fz52ksjyqm933rlqwa2zzv2a3v2b70cs224gidg";
  };

  doCheck = true;
  buildInputs = [ setuptools ];
  propagatedBuildInputs = [ jupyterlab ];

  meta = with lib; {
    description = "A JupyterLab extension for embedding drawio / mxgraph.";
    homepage = "https://pypi.org/project/jupyterlab-drawio/";
    license = licenses.bsd3;
    maintainers = [];
  };
}
