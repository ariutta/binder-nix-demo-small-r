{ lib
, buildPythonPackage
, fetchPypi
, jupyter_packaging
, jupyter_server
, notebook
}:

buildPythonPackage rec {
  pname = "nbclassic";
  version = "0.2.6";
  name = "${pname}-${version}";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1s04f518sny18anwpp56swkyifsskq4fzphmh6x33isxz1pl6jdn";
  };

  doCheck = true;
  propagatedBuildInputs = [
    jupyter_server
    notebook
    jupyter_packaging
  ];

  meta = with lib; {
    description = "Jupyter Notebook as a Jupyter Server Extension.";
    longDescription = "NBClassic runs the Jupyter Notebook frontend on the Jupyter Server backend.";
    homepage = "https://pypi.org/project/nbclassic/";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
  };
}
