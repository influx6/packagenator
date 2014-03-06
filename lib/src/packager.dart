part of packagenator.core;

class Packager{
	Versionator versions = Versionator.create();
	Linkator linker = Linkator.create();
	Future<fs.GuardedDirectory> dir;
	
	static Map env = new Map.from(Platform.environment);
	static Function penv = Enums.nthFor(Packager.env);
	static String packageStore = paths.join(Packager.penv('HOME'),'dart_packages');
	static fs.GuardedFS packages = fs.GuardedFS.create(Packager.packageStore,false);
	static fs.GuardedFS current = fs.GuardedFS.create('.',false);
  static String scriptRoot = paths.normalize(paths.join(Platform.script.toFilePath(),'../..'));
	static fs.GuardedFS templates = fs.GuardedFS.create(paths.join(Packager.scriptRoot,'./lib/src/templates'),true);

	static Future findInstalled(String name){
		return Packager.packages.fsCheck(paths.join(Packager.packageStore,name)).then((path){
			return Packager.create(Packager.packages.Dir(name));
		});
	}

	static create(d) => new Packager(d);

	Packager(this.dir){
		this.versions.use(this.dir);
	}

	Future useVersion(String ver){
		this.versions.validateVersion(ver).then((f){
			if(f.isEmpty) return new Future.error('NotValid');
			this.dir.then((d){
		     this.linker.use(new Future.value(d.createNewDir(Enums.last(f))));
			});
		});
	}

	Future listVersions(){
		return this.versions.retrieveVersions();
	}

	void endSession(){
		return Funcs.when(Valids.exist(this.dir),(){
			this.dir = null;
			this.versions = null;
		},(){
			this.versions = null;
		});
	}

}
