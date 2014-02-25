part of packagenator.core;


class Linkator{
	Future<fs.GuardedDirectory> dir;

	static create() => new Linkator();
	
	Linkator();

	void use(Future<fs.GuardedDirectory> d){
		this.dir = d;
	}

	Future createLink(String path){
		return Funcs.when(Valids.exist(this.dir),(){
			return this.dir.then((d){
				return d.linkTo(path);
			});
		},(){
			return new Future.error(new Exception('Versionator not ready!'));
		});
	}

	Future removeLink(String path){
		return Funcs.when(Valids.exist(this.dir),(){
			return this.dir.then((d){
				return d.unlinkTo(path);
			});
		},(){
			return new Future.error(new Exception('Versionator not ready!'));
		});
	}

	Future renameLink(String path){
		return Funcs.when(Valids.exist(this.dir),(){
			return this.dir.then((d){
				return d.renameLinkTo(path);
			});
		},(){
			return new Future.error(new Exception('Versionator not ready!'));
		});
	}
	
}