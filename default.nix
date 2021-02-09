with builtins;
let
  #4
  # this corresponds to notebook_dir (impure)
  rootDirectoryImpure = toString ./.;
  shareDirectoryImpure = "${rootDirectoryImpure}/share-jupyter";
  jupyterlabDirectoryImpure = "${rootDirectoryImpure}/share-jupyter/lab";
  # Path to the JupyterWith folder.
  jupyterWithPath = builtins.fetchGit {
    url = https://github.com/tweag/jupyterWith;
    rev = "35eb565c6d00f3c61ef5e74e7e41870cfa3926f7";
  };

  # Importing overlays from that path.
  overlays = [
    # my custom python overlays
    (import ./python-overlay.nix)
    # jupyterWith overlays
    # Necessary for Jupyter
    (import "${jupyterWithPath}/nix/python-overlay.nix")
    (import "${jupyterWithPath}/nix/overlay.nix")
  ];

  # Your Nixpkgs snapshot, with JupyterWith packages.
  pkgs = import <nixpkgs> { inherit overlays; };

  jupyterExtraPython = (pkgs.python3.withPackages (ps: with ps; [ 
    # Declare all server extensions in here, plus anything else needed.

    #-----------------
    # Language Server
    #-----------------

    jupyter_lsp

    # Even when it's specified here, we also need to specify it in
    # jupyterEnvironment.extraPackages for the LS for R to work.
    # TODO: why?
    jupyterlab-lsp
    # jupyterlab-lsp also supports other languages:
    # https://jupyterlab-lsp.readthedocs.io/en/latest/Language%20Servers.html#NodeJS-based-Language-Servers

    # The formatter for Python code is working, but formatR for R code is not.

    python-language-server
    # others also available

    #-----------------
    # Code Formatting
    #-----------------

    jupyterlab_code_formatter

    #-----------------
    # Other
    #-----------------

    jupytext

    # TODO: is this needed here?
    jupyter_packaging
  ]));

  # From here, everything happens as in other examples.
  jupyter = pkgs.jupyterWith;

  #########################
  # R
  #########################

  myRPackages = p: with p; [
    #------------
    # for Jupyter
    #------------
    formatR
    languageserver

    #----------------
    # not for Jupyter
    #----------------
    pacman

    tidyverse
    # tidyverse includes the following:
    # ggplot2 
    # purrr   
    # tibble  
    # dplyr   
    # tidyr   
    # stringr 
    # readr   
    # forcats 

    knitr
  ];

  myR = [ pkgs.R ] ++ (myRPackages pkgs.rPackages);

  irkernel = jupyter.kernels.iRWith {
    # Identifier that will appear on the Jupyter interface.
    name = "pkgs_on_IRkernel";
    # Libraries to be available to the kernel.
    packages = myRPackages;
    # Optional definition of `rPackages` to be used.
    # Useful for overlaying packages.
    rPackages = pkgs.rPackages;
  };

#  # It appears juniper doesn't work anymore
#  juniper = jupyter.kernels.juniperWith {
#    # Identifier that will appear on the Jupyter interface.
#    name = "JuniperKernel";
#    # Libraries (R packages) to be available to the kernel.
#    packages = myRPackages;
#    # Optional definition of `rPackages` to be used.
#    # Useful for overlaying packages.
#    # TODO: why not just do this in overlays above?
#    #rPackages = pkgs.rPackages;
#  };

  jupyterEnvironment =
    jupyter.jupyterlabWith {
      directory = jupyterlabDirectoryImpure;
      kernels = [ irkernel ];
      extraPackages = p: [
        # needed by nbconvert
        p.pandoc
        # see https://github.com/jupyter/nbconvert/issues/808
        #tectonic
        # more info: https://nixos.wiki/wiki/TexLive
        p.texlive.combined.scheme-full

        # TODO: these dependencies are only required when want to build a lab
        # extension from source.
        # Does jupyterWith allow me to specify them as buildInputs?
        p.nodejs
        p.yarn

        jupyterExtraPython

        # jupyterlab-lsp must be specified here in order for the LSP for R to work.
        # TODO: why isn't it enough that this is specified for jupyterExtraPython?
        p.python3Packages.jupyterlab-lsp
      ];

      extraJupyterPath = pkgs:
        concatStringsSep ":" [
          "${jupyterExtraPython}/lib/${jupyterExtraPython.libPrefix}/site-packages"
          "${pkgs.rPackages.formatR}/library/formatR/R"
          "${pkgs.rPackages.languageserver}/library/languageserver/R"
        ];
    };
in
  jupyterEnvironment.env.overrideAttrs (oldAttrs: {
    shellHook = oldAttrs.shellHook + ''
    # this is needed in order that tools like curl and git can work with SSL
    if [ ! -f "$SSL_CERT_FILE" ] || [ ! -f "$NIX_SSL_CERT_FILE" ]; then
      candidate_ssl_cert_file=""
      if [ -f "$SSL_CERT_FILE" ]; then
        candidate_ssl_cert_file="$SSL_CERT_FILE"
      elif [ -f "$NIX_SSL_CERT_FILE" ]; then
        candidate_ssl_cert_file="$NIX_SSL_CERT_FILE"
      else
        candidate_ssl_cert_file="/etc/ssl/certs/ca-bundle.crt"
      fi
      if [ -f "$candidate_ssl_cert_file" ]; then
          export SSL_CERT_FILE="$candidate_ssl_cert_file"
          export NIX_SSL_CERT_FILE="$candidate_ssl_cert_file"
      else
        echo "Cannot find a valid SSL certificate file. curl will not work." 1>&2
      fi
    fi
    # TODO: is the following line ever useful?
    #export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt

    # set SOURCE_DATE_EPOCH so that we can use python wheels
    SOURCE_DATE_EPOCH=$(date +%s)

    export JUPYTERLAB_DIR="${jupyterlabDirectoryImpure}"
    export JUPYTER_CONFIG_DIR="${shareDirectoryImpure}/config"
    export JUPYTER_DATA_DIR="${shareDirectoryImpure}"
    export JUPYTER_RUNTIME_DIR="${shareDirectoryImpure}/runtime"

    # mybinder gave this message when launching:
    # Installation finished!  To ensure that the necessary environment
    # variables are set, either log in again, or type
    # 
    #   . /home/jovyan/.nix-profile/etc/profile.d/nix.sh
    # 
    # in your shell.

    if [ -f /home/jovyan/.nix-profile/etc/profile.d/nix.sh ]; then
       . /home/jovyan/.nix-profile/etc/profile.d/nix.sh
    fi

    mkdir -p "$JUPYTER_DATA_DIR"
    mkdir -p "$JUPYTER_RUNTIME_DIR"

    ##################
    # specify configs
    ##################

    rm -rf "$JUPYTER_CONFIG_DIR"
    mkdir -p "$JUPYTER_CONFIG_DIR"

    # TODO: which of way of specifying server configs is better?
    # 1. jupyter_server_config.json (single file w/ all jpserver_extensions.)
    # 2. jupyter_server_config.d/ (directory holding multiple config files)
    #                            jupyterlab.json
    #                            jupyterlab_code_formatter.json
    #                            ... 

    #----------------------
    # jupyter_server_config
    #----------------------
    # We need to set root_dir in config so that this command:
    #   direnv exec ~/Documents/myenv jupyter lab start
    # always results in root_dir being ~/Documents/myenv.
    # Otherwise, running that command from $HOME makes root_dir be $HOME.
    #
    # TODO: what is the difference between these two:
    # - ServerApp.jpserver_extensions
    # - NotebookApp.nbserver_extensions
    #
    # TODO: what's the point of the following check?
    if [ -f "$JUPYTER_CONFIG_DIR/jupyter_server_config.json" ]; then
      echo "File already exists: $JUPYTER_CONFIG_DIR/jupyter_server_config.json" >/dev/stderr
      exit 1
    fi
    #
    # If I don't include jupyterlab_code_formatter in
    # ServerApp.jpserver_extensions, I get the following error
    #   Jupyterlab Code Formatter Error
    #   Unable to find server plugin version, this should be impossible,open a GitHub issue if you cannot figure this issue out yourself.
    #
    echo '{"ServerApp": {"root_dir": "${rootDirectoryImpure}", "jpserver_extensions":{"nbclassic":true,"jupyterlab":true,"jupyterlab_code_formatter":true}}}' >"$JUPYTER_CONFIG_DIR/jupyter_server_config.json"

    #------------------------
    # jupyter_notebook_config
    #------------------------
    # The packages listed by 'jupyter-serverextension list' come from
    # what is specified in ./config/jupyter_notebook_config.json.
    # Yes, it does appear that 'server extensions' are indeed specified in
    # jupyter_notebook_config, not jupyter_server_config. That's confusing.
    #
    echo '{ "NotebookApp": { "nbserver_extensions": { "jupyterlab": true, "jupytext": true, "jupyter_lsp": true, "jupyterlab_code_formatter": true }}}' >"$JUPYTER_CONFIG_DIR/jupyter_notebook_config.json"

    #-------------------
    # widgetsnbextension
    #-------------------
    # Not completely sure why this is needed, but without it, things didn't work.
    mkdir -p "$JUPYTER_CONFIG_DIR/nbconfig/notebook.d"
    echo '{"load_extensions":{"jupyter-js-widgets/extension":true}}' >"$JUPYTER_CONFIG_DIR/nbconfig/notebook.d/widgetsnbextension.json"

    #################################
    # symlink prebuilt lab extensions
    #################################

    rm -rf "$JUPYTER_DATA_DIR/labextensions"
    mkdir -p "$JUPYTER_DATA_DIR/labextensions"

    # Note the prebuilt lab extensions are distributed via PyPI as "python"
    # packages, even though they are really JS, HTML and CSS.
    #
    # Symlink targets may generally use snake-case, but not always.
    #
    # The lab extension code appears to be in two places in the python packge:
    # 1) lib/python3.8/site-packages/snake_case_pkg_name/labextension
    # 2) share/jupyter/labextensions/dash-case-pkg-name
    # These directories are identical, except share/... has file install.json.

    # jupyterlab_hide_code
    ln -s "${pkgs.python3Packages.jupyterlab_hide_code}/share/jupyter/labextensions/jupyterlab-hide-code" "$JUPYTER_DATA_DIR/labextensions/jupyterlab-hide-code"

    # @axlair/jupyterlab_vim
    mkdir -p "$JUPYTER_DATA_DIR/labextensions/@axlair"
    ln -s "${pkgs.python3Packages.jupyterlab_vim}/lib/python3.8/site-packages/jupyterlab_vim/labextension" "$JUPYTER_DATA_DIR/labextensions/@axlair/jupyterlab_vim"

    # jupyterlab-vimrc
    ln -s "${pkgs.python3Packages.jupyterlab-vimrc}/lib/python3.8/site-packages/jupyterlab-vimrc" "$JUPYTER_DATA_DIR/labextensions/jupyterlab-vimrc"

    # @krassowski/jupyterlab-lsp
    mkdir -p "$JUPYTER_DATA_DIR/labextensions/@krassowski"
    ln -s "${pkgs.python3Packages.jupyterlab-lsp}/share/jupyter/labextensions/@krassowski/jupyterlab-lsp" "$JUPYTER_DATA_DIR/labextensions/@krassowski/jupyterlab-lsp"

    # @ryantam626/jupyterlab_code_formatter
    mkdir -p "$JUPYTER_DATA_DIR/labextensions/@ryantam626"
    ln -s "${pkgs.python3Packages.jupyterlab_code_formatter}/share/jupyter/labextensions/@ryantam626/jupyterlab_code_formatter" "$JUPYTER_DATA_DIR/labextensions/@ryantam626/jupyterlab_code_formatter"

    # TODO: the following doesn't work at the moment
#    # @aquirdturtle/collapsible_headings
#    mkdir -p "$JUPYTER_DATA_DIR/labextensions/@aquirdturtle/collapsible_headings"
    ln -s "${pkgs.python3Packages.aquirdturtle_collapsible_headings}/share/jupyter/labextensions/@aquirdturtle/collapsible_headings" "$JUPYTER_DATA_DIR/labextensions/@aquirdturtle/collapsible-headings"

    # TODO: check whether this works.
#    # jupyterlab-system-monitor depends on jupyterlab-topbar and jupyter-resource-usage
#
#    # jupyterlab-topbar
#    ln -s "${pkgs.python3Packages.jupyterlab-topbar}/lib/python3.8/site-packages/jupyterlab-topbar/labextension" "$JUPYTER_DATA_DIR/labextensions/jupyterlab-topbar"
#
#    # jupyter-resource-usage
#    ln -s "${pkgs.python3Packages.jupyter-resource-usage}/lib/python3.8/site-packages/jupyter-resource-usage/labextension" "$JUPYTER_DATA_DIR/labextensions/jupyter-resource-usage"
#
#    # jupyterlab-system-monitor
#    ln -s "${pkgs.python3Packages.jupyterlab-system-monitor}/lib/python3.8/site-packages/jupyterlab-system-monitor/labextension" "$JUPYTER_DATA_DIR/labextensions/jupyterlab-system-monitor"

    if [ ! -d "$JUPYTERLAB_DIR" ]; then
      # We are overwriting everything else, but we only run this section when
      # "$JUPYTERLAB_DIR" is missing, because the build step is time intensive.

      mkdir -p "$JUPYTERLAB_DIR"
      mkdir -p "$JUPYTERLAB_DIR/staging"

      #########################
      # build jupyter lab alone
      #########################

      # Note: we pipe stdout to stderr because otherwise $(cat "$\{dump\}")
      # would contain something that should not be evaluated.
      # Look at 'eval $(cat "$\{dump\}")' in ./.envrc file.

      chmod -R +w "$JUPYTERLAB_DIR/staging/"
      jupyter lab build 1>&2

      ###############################
      # add any source lab extensions
      ###############################

      # A source lab extension is a raw JS package, and it must be compiled.

      ############################################
      # build jupyter lab w/ source lab extensions
      ############################################

      # It would be nice to be able to just build once here at the end, but the
      # build process appears to fail unless I build once for jupyter lab alone
      # then again after adding source lab extensions.

      #chmod -R +w "$JUPYTERLAB_DIR/staging/"
      #jupyter lab build 1>&2

      #chmod -R -w "$JUPYTERLAB_DIR/staging/"
    fi

    ###########
    # Settings
    ###########

    # Specify a font for the Terminal to make the Powerline prompt look OK.
    # TODO: should we install the fonts as part of this Nix definition?
    # TODO: one setting is '"theme": "inherit"'. Where does it inherit from?
    # is it @jupyterlab/apputils-extension:themes.theme?

    mkdir -p "$JUPYTERLAB_DIR/settings"
    touch "$JUPYTERLAB_DIR/settings/overrides.json"
    rm "$JUPYTERLAB_DIR/settings/overrides.json"
    echo '{"jupyterlab-vimrc:vimrc": {"imap": [["jk", "<Esc>"]]}, "@jupyterlab/terminal-extension:plugin":{"fontFamily":"Meslo LG S DZ for Powerline,monospace"}}' >"$JUPYTER_DATA_DIR/lab/settings/overrides.json"

    # Setting for tab manager being on the right is something like this:
    # "@jupyterlab/application-extension:sidebar": {"overrides": {"tab-manager": "right"}}
    #
    # "@jupyterlab/extensionmanager-extension:plugin": {"enabled": false}
    #
    '';
  })
