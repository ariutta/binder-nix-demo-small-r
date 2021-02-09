{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, jupyter_packaging
, jupyterlab_server
, ipython
, packaging
, tornado
, jupyter_core
, jupyter_server
, nbclassic
, jinja2
}:

buildPythonPackage rec {
  pname = "jupyterlab";
  version = "3.0.6";
  disabled = pythonOlder "3.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0j4sz89xrnbfdmf942b4y58s6qv1w8g0d63njhhf93pfg95k99ah";
  };

  propagatedBuildInputs = [
    jupyter_packaging
    jupyterlab_server
    ipython
    packaging
    tornado
    jupyter_core
    jupyter_server
    nbclassic
    jinja2
  ];

  makeWrapperArgs = [
    "--set" "JUPYTERLAB_DIR" "$out/share/jupyter/lab"
  ];

  # Depends on npm
  doCheck = false;

  meta = with lib; {
    description = "Jupyter lab environment notebook server extension.";
    license = with licenses; [ bsd3 ];
    homepage = "https://jupyter.org/";
    # or should it be https://github.com/jupyterlab/jupyterlab
    maintainers = with maintainers; [ zimbatm costrouc ];
  };
}
