{ lib
, buildPythonPackage
, fetchPypi
, yapf
, black
, ipython
}:

buildPythonPackage rec {
  pname = "nb_black";
  version = "1.0.7";
  name = "${pname}-${version}";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0aynnsqnmrvkc7awx7li1zvbwlgrz2hp7b3rdl56lpv78qx2x98w";
  };

  doCheck = true;

  propagatedBuildInputs = [
    yapf
    black
    ipython
    #ipython_genutils
  ];

  meta = with lib; {
    description = "Format Python in Jupyter with Black.";
    longDescription = ''
      A simple extension for Jupyter Notebook and Jupyter Lab to beautify Python
      code automatically using black.
      '';
    homepage = "https://pypi.org/project/nb_black/";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
