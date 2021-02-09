{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, jupyterlab
}:

buildPythonPackage rec {
  pname = "jupyterlab-topbar";
  version = "0.6.1";
  name = "${pname}-${version}";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0pzv4sba9khqh3mfwj4wgnb61935dkr651ip3y9bhacws17i9ygi";
  };

  doCheck = true;
  buildInputs = [ setuptools ];
  propagatedBuildInputs = [ jupyterlab ];

  meta = with lib; {
    description = "JupyterLab extension to expose the top bar space.";
    homepage = "https://pypi.org/project/jupyterlab-topbar/";
    license = licenses.bsd3;
    maintainers = [];
  };
}
