{
  description = "Development environment";

  inputs = {
    nixpkgs = { url = "github:NixOS/nixpkgs/nixpkgs-unstable"; };
    flake-utils = { url = "github:numtide/flake-utils"; };
  };

  outputs = { self, nixpkgs, flake-utils }:
     flake-utils.lib.eachDefaultSystem (system:
      let 
				pkgs = import nixpkgs { inherit system; };
				version = builtins.substring 0 8 self.lastModifiedDate;
      in
       {
			 		packages = {
						default = pkgs.buildGoModule {
							pname = "go-hello-nix";
						  inherit version;
              src = ./.;
							#vendorSha256 = pkgs.lib.fakeSha256;
							vendorSha256 = "sha256-pQpattmS9VmO3ZIQUFn66az8GSmB4IvYhTTCFn6SUmo=";
            	};
						docker = let 
							 web = self.packages.${system}.default;
  					in pkgs.dockerTools.buildLayeredImage {
    				name = web.pname;
    				tag = web.version;
    				contents = [ web ];

    				config = {
      				Cmd = [ "/bin/app1" ];
      				WorkingDir = "/";
    				};
  				};
					};
					app.${system}.app1= {
            type = "app";
            program = "${self.packages.${system}.default}/bin/app1";
          };
					app.${system}.app2= {
            type = "app";
            program = "${self.packages.${system}.default}/bin/app2";
          };
          devShell = pkgs.mkShell
          {
            buildInputs = [
   						pkgs.go_1_18
            	pkgs.gotools
            	pkgs.golangci-lint
            	pkgs.gopls
            	pkgs.go-outline
            	pkgs.gopkgs 
            ];
						shellHook = ''
          		echo hi
        		'';
          };
      });
	}
