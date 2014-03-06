part of packagenator.core;

abstract class CustomRequestor{
	final Streamable stream = streams.Streamable.create();
	void request(v,k,m);
}

class Requestor{
	final Streamable stream = streams.Streamable.create();
	final Map meta = new Map();
	final MapDecorator plugins = MapDecorator.create();

	static create() => new Requestor();

	Requestor(){
		this.addPlugin('path',PathRequestor.create(Packager.current.Dir('.')));
		this.addPlugin('dartpath',DartPathRequestor.create(Packager.current.Dir('.')));
		this.addPlugin('git',GitRequestor.create(Packager.current.Dir('.')));
		this.addPlugin('http',HttpRequestor.create(Packager.current.Dir('.')));
		this.addPlugin('pub',PubRequestor.create(Packager.current.Dir('.')));
		this.addPlugin('localpub',LocalPubRequestor.create(Packager.current.Dir('.')));
	}

	void use(Map meta){
		this.meta.clear();
		this.meta.addAll(meta);
	}

	void requestDependencies(){
		var finder = Enums.nthFor(this.meta);
		var depends = finder('depends');

		if(Valids.notExist(finder('install_dir'))) throw "install_dir path not in config: \n${this.meta}";

		Packager.current.fsCheck(finder('install_dir')).then((p){

			depends.forEach((v,k){
				
				var find = Enums.nthFor(k);

				if(Valids.notExist(find('type'))) return null;

				if(!this.hasPlugin(find('type'))) return null;

				return this.plugin(find('type')).request(v,k,this.meta);
				
			});

		}).catchError((e){
			if(e is FileSystemException) throw "${finder('install_dir')} not found!";
			throw e;
		});

	}

	CustomRequestor plugin(String tag){
		tag = tag.toLowerCase();
		if(this.plugins.has(tag)) return this.plugins.get(tag);
		return null;
	}

	bool hasPlugin(String tag){
		tag = tag.toLowerCase();
		return this.plugins.has(tag);
	}

	void addPlugin(String tag,CustomRequestor c){
		tag = tag.toLowerCase();
		c.stream.on(this.stream.emit);
		this.plugins.add(tag,c);
	}

	void removePlugin(String tag){
		tag = tag.toLowerCase();
		var c = this.plugins.destroy(tag);
		c.stream.off(this.stream.emit)
	}

}

class PathRequestor extends CustomRequestor{
	Future<fs.GuardedDirectory> r;

	static create(d) => new PathRequestor(d);

	PathRequestor(this.r);

	void request(String id,Map meta,Map parent){
		var pfinder = Enums.nthFor(parent);
		var finder = Enums.nthFor(meta);

		if(Valids.notExist(finder('url'))) return null;

		var core = fs.GuardedDirectory.create(finder('url'),true);
		core.fsCheck('.').then((path){

			Packager.current.Dir(pfinder('install_dir')).then((dir){

				var to = paths.normalize(paths.join(dir.path,id));
				core.linkTo(to).then((link){
					this.stream.emit('Request Fulfilled for: $id , Meta: $meta');
				});
			});

		}).catchError((e){
			throw e;
		});
			
	}
}

class LocalPubRequestor extends CustomRequestor{
	Future<fs.GuardedDirectory> r;
	
	static create(d) => new LocalPubRequestor(d);

	LocalPubRequestor(this.r);
	
	void request(String id,Map meta,Map parent){
		var pfinder = Enums.nthFor(parent);
		var finder = Enums.nthFor(meta);
		
		if(Valids.notExist(finder('url'))) return null;

		var next = (ready){

			package.dir.createNewDir(Enums.last(ready)).then((avail){

				print('Available: $avail');

			}).catchError((e){
				throw e;
			});

		};

		Packager.getInstalled(id).then((package){

			if(Valids.exist(finder('version')) && !Version.validVersionNumber(finder('version'))) throw """
				Version Number ${finder('version')} is invalid!
				Versions should only be in the range of MajorNumber.MinorNumber.MinorNumber ,e.g
					in any of the following way: 0.0.2 , > 0.0.2 , >= 0.2.0 , < 0.0.2 , <= 0.0.2
			""";

			if(Valids.exist(finder('version'))) 
				return package.version.validateVersion(finder('version')).then((ready){
					if(ready.isEmpty) return package.listVersions().then((vers){
						this.stream.emit("Version ${finder('version')} unavailable, Available Versions: $vers");
					});

					next(ready);
				});

			return package.listVersions().then(ready);

		}).catch((e){
			if(e is FileSystemException) this.stream.emit('$id does not exist in local pub cache!');
			throw e;
		});

	}

}

class DartPathRequestor extends PathRequestor{

	static create(d) => new DartPathRequestor(d);

	DartPathRequestor(r): super(r);

	void request(String id,Map meta,Map parent){
		if(meta.containsKey('url')) meta['url'] = paths.normalize(paths.join(meta['url'],'lib'));
		super.request(id,meta,parent);
	}
}


class GitRequestor extends CustomRequestor{
	Future<fs.GuardedDirectory> r;

	static create(d) => new GitRequestor(d);
	GitRequestor(this.r);

	void request(String id,Map meta,Map parent){
		var pfinder = Enums.nthFor(parent);
		var finder = Enums.nthFor(meta);
	}

}

class HttpRequestor extends CustomRequestor{
	Future<fs.GuardedDirectory> r;

	static create(r) => new GitRequestor(r);

	HttpRequestor(this.r);
	
	void request(String id,Map meta,Map parent){
		var pfinder = Enums.nthFor(parent);
		var finder = Enums.nthFor(meta);
	}

}

class PubRequestor extends HttpRequestor{

	static create(d) => new PubRequestor(d);

	PubRequestor(r): super(r);
	
	void request(String id,Map meta,Map parent){
		var pfinder = Enums.nthFor(parent);
		var finder = Enums.nthFor(meta);
	}

}
