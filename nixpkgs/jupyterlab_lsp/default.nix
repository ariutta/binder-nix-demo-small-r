{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, jupyter_lsp
, jupyterlab
, R
, rPackages
}:

buildPythonPackage rec {
  pname = "jupyterlab-lsp";
  version = "3.3.0";
  name = "${pname}-${version}";

  src = fetchPypi {
    inherit pname version;
    sha256 = "10c2cdkc85pxi24v3i9k19krbn9s8b7qvsv8dqy9fr8jmf03yj80";
  };

  doCheck = true;
  buildInputs = [ setuptools ];
  propagatedBuildInputs = [
    jupyter_lsp
    jupyterlab

    # These two are required for rPackages.languageserver to be able load.
    R
    rPackages.languageserver

    # TODO: must we specify in this file every language server we want?
  ];

  meta = with lib; {
    description = "Language Server Protocol integration for JupyterLab.";
    homepage = "https://pypi.org/project/jupyterlab-lsp/";
    license = licenses.bsd3;
    maintainers = [];
  };
}
