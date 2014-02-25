part of packagenator.core;

class Requestor{
	final Map meta = new Map();
	PathRequestor pather;
	GitRequestor git;
	HttpRequestor req;
	PubRequestor pub;


	static create() => new Requestor();

	Requestor(){
		this.pather = PathRequestor.create(Packager.current.Dir('.'));
		this.git = GitRequestor.create(Packager.current.Dir('.'));
		this.req = HttpRequestor.create(Packager.current.Dir('.'));
		this.pub = PubRequestor.create(Packager.current.Dir('.'));
	}

	void use(Map meta){
		this.meta.clear();
		this.meta.addAll(meta);
	}

	void requestDependencies(){
		var finder = Enums.nthFor(this.meta);
		var depends = finder('depends');

		depends.forEach((v,k){

			var find = Enums.nthFor(k);

			Funcs.when(Valids.match(find('type'),'path'),(){
				this.pather.request(v,k);
			});

			Funcs.when(Valids.match(find('type'),'git'),(){
				this.git.request(v,k);
			});
			
			Funcs.when(Valids.match(find('type'),'pub'),(){
				this.pub.request(v,k);
			});
			
			Funcs.when(Valids.match(find('type'),'http'),(){
				this.req.request(v,k);
			});
			
		})
	}
}

class PathRequestor{
	Future<fs.GuardedDirectory> r;

	static create(d) => new PathRequestor(d);

	PathRequestor(this.p);

	void request(String id,Map meta){
		var finder = Enusm.nthFor(meta);
		Funcs.when(Valids.match(finder('type'),'path'),(){

			
		});
	}
}

class GitRequestor{
	Future<fs.GuardedDirectory> r;

	static create(d) => new GitRequestor(d);
	GitRequestor(this.r);

	void request(String id,Map meta){
		var finder = Enusm.nthFor(meta);
		Funcs.when(Valids.match(finder('type'),'git'),(){
			
		});
	}

}

class HttpRequestor{
	Future<fs.GuardedDirectory> r;

	static create() => new GitRequestor();

	HttpRequestor(this.r);
	
	void request(String id,Map meta){
		var finder = Enusm.nthFor(meta);
		Funcs.when(Valids.match(finder('type'),'http'),(){
			
		});
	}

}

class PubRequestor extends HttpRequestor{
	Future<fs.GuardedDirectory> r;

	static create(d) => new PubRequestor(d);

	PubRequestor(this.r);
	
	void request(String id,Map meta){
		var finder = Enusm.nthFor(meta);
		Funcs.when(Valids.match(finder('type'),'pub'),(){
			
		});
	}

}